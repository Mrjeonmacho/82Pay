from __future__ import annotations

import base64
import json
import re
from typing import Any, Dict, List, Optional, Tuple
from urllib.parse import urlparse

from ocr.base import OCREngine

from .bank_patterns import get_pattern_match_info, resolve_bank_name
from .client import ChatCompletionsHttpError, chat_completions
from .config import (
    get_api_key,
    get_api_url,
    get_gpt_upstream_b64_threshold,
    get_gpt_upstream_fallback_jpeg_quality,
    get_gpt_upstream_fallback_max_side,
    get_gpt_upstream_jpeg_quality,
    get_gpt_upstream_max_side,
    get_instruction_role,
    get_max_completion_tokens,
    get_model,
    get_timeout_sec,
)
from .image_prep import encode_bgr_for_gpt_upstream
from .postprocess_gpt import extract_account_number
from .prompts import build_developer_prompt


def _log(msg: str) -> None:
    print(f"[gpt-ocr] {msg}", flush=True)


# extract_account_number 가 OCRBoxItem 의 box 좌표를 쓰므로 GPT 줄 단위에 더미 박스 필요
_GPT_LINE_PLACEHOLDER_BOX: List[List[float]] = [
    [0.0, 0.0],
    [400.0, 0.0],
    [400.0, 40.0],
    [0.0, 40.0],
]


def _bgr_to_data_url_gpt_upstream(img_bgr: Any) -> Tuple[str, Dict[str, Any]]:
    """
    GMS Chat Completions 전송용: PIL로 축소·JPEG 재인코딩 후 data URL.
    base64 길이가 임계값을 넘으면 원본 BGR에서 한 번 더 강하게 축소한다.
    """
    max_side = get_gpt_upstream_max_side()
    quality = get_gpt_upstream_jpeg_quality()
    gpt_bytes, info = encode_bgr_for_gpt_upstream(
        img_bgr, max_side=max_side, jpeg_quality=quality
    )
    b64 = base64.b64encode(gpt_bytes).decode("ascii")
    print("[gpt-ocr] optimized_bytes =", len(gpt_bytes), flush=True)
    print("[gpt-ocr] optimized_b64_chars =", len(b64), flush=True)

    threshold = get_gpt_upstream_b64_threshold()
    if len(b64) > threshold:
        fs = get_gpt_upstream_fallback_max_side()
        fq = get_gpt_upstream_fallback_jpeg_quality()
        _log(
            f"gpt 업스트림 이미지 2차 축소 | b64_chars={len(b64)} > threshold={threshold} "
            f"max_side {max_side}→{fs} quality {quality}→{fq}"
        )
        gpt_bytes, info = encode_bgr_for_gpt_upstream(
            img_bgr, max_side=fs, jpeg_quality=fq
        )
        b64 = base64.b64encode(gpt_bytes).decode("ascii")
        info["prep_pass"] = 2
        print("[gpt-ocr] optimized_bytes =", len(gpt_bytes), flush=True)
        print("[gpt-ocr] optimized_b64_chars =", len(b64), flush=True)
    else:
        info["prep_pass"] = 1

    data_url = f"data:image/jpeg;base64,{b64}"
    info["b64_chars"] = len(b64)
    info["data_url_chars"] = len(data_url)
    return data_url, info


def _extract_json_object(text: str) -> Dict[str, Any]:
    text = text.strip()
    if not text:
        raise ValueError("empty model response")

    fence = re.match(r"^```(?:json)?\s*([\s\S]*?)\s*```\s*$", text, re.IGNORECASE)
    if fence:
        text = fence.group(1).strip()

    try:
        parsed = json.loads(text)
    except json.JSONDecodeError:
        start = text.find("{")
        end = text.rfind("}")
        if start >= 0 and end > start:
            parsed = json.loads(text[start : end + 1])
        else:
            raise
    if not isinstance(parsed, dict):
        raise ValueError("model JSON is not an object")
    return parsed


def _normalize_account_digits(raw: Optional[str]) -> Optional[str]:
    if not raw:
        return None
    digits = re.sub(r"[^0-9]", "", str(raw))
    if len(digits) < 9 or len(digits) > 16:
        return None
    return digits


def _merge_gpt_account_with_postprocess(
    bank_name: Optional[str],
    account_gpt: Optional[str],
    items: List[Dict[str, Any]],
    full_text: str,
) -> tuple[Optional[str], str]:
    """
    GPT가 짧은 계좌만 줄 때 Paddle과 동일한 extract_account_number 로
    full_text 에서 후보를 다시 뽑아 bank_patterns 에 더 잘 맞는 쪽을 선택한다.
    """
    ft = (full_text or "").strip()
    if not bank_name or not ft or not items:
        return account_gpt, "gpt_only"

    refined = extract_account_number(items, ft, bank_name=bank_name)
    pi_g = get_pattern_match_info(bank_name, account_gpt)
    pi_r = get_pattern_match_info(bank_name, refined) if refined else None
    matched_g = bool(pi_g.get("matched"))
    matched_r = bool(pi_r.get("matched")) if pi_r else False

    if refined and matched_r and not matched_g:
        return refined, "postprocess_pattern_fix"
    if refined and not account_gpt:
        return refined, "postprocess_fill"
    if refined and matched_r and matched_g:
        sg = float(pi_g.get("best_score", 0))
        sr = float(pi_r.get("best_score", 0))
        if sr > sg:
            return refined, "postprocess_higher_score"
    return account_gpt, "gpt"


def _message_content_with_image(img_data_url: str) -> List[Dict[str, Any]]:
    return [
        {"type": "text", "text": "이 이미지에서 bank_name, account_number, full_text를 추출하라."},
        {
            "type": "image_url",
            "image_url": {"url": img_data_url, "detail": "low"},
        },
    ]


class GptOCREngine(OCREngine):
    name = "gpt"

    def recognize(self, img_bgr, *, preprocess_mode: str = "basic") -> Dict[str, Any]:
        _log(
            f"인식 시작 | engine={self.name} preprocess_mode={preprocess_mode!r} "
            f"instruction_role={get_instruction_role()!r}"
        )

        api_key = get_api_key()
        if not api_key:
            _log("오류: API 키 없음 (GPT_OCR_API_KEY / GMS_KEY)")
            raise ValueError(
                "GPT OCR API 키가 없습니다. 환경변수 GPT_OCR_API_KEY 또는 GMS_KEY를 설정하세요. "
                "(로컬: backend/.env, 배포: 플랫폼 credential)"
            )

        img_url, enc_info = _bgr_to_data_url_gpt_upstream(img_bgr)
        _log(
            f"gpt 업스트림 이미지 | prep_pass={enc_info.get('prep_pass')} "
            f"원본WxH={enc_info['orig_wh']} 전송WxH={enc_info['out_wh']} "
            f"resized={enc_info['resized']} max_side_cap={enc_info['max_side_cap']} "
            f"jpeg_q={enc_info['jpeg_quality']} jpeg_bytes={enc_info['jpeg_bytes']} "
            f"b64_chars={enc_info['b64_chars']}"
        )

        api_url = get_api_url()
        host = urlparse(api_url).netloc or api_url[:48]
        max_completion_tokens = get_max_completion_tokens()
        _log(
            f"Chat Completions 요청 | model={get_model()!r} host={host!r} "
            f"max_completion_tokens={max_completion_tokens} "
            f"timeout_sec={get_timeout_sec()} api_key={'설정됨(***)' if api_key else '없음'}"
        )

        role = get_instruction_role()
        messages = [
            {"role": role, "content": build_developer_prompt()},
            {"role": "user", "content": _message_content_with_image(img_url)},
        ]

        payload: Dict[str, Any] = {
            "model": get_model(),
            "messages": messages,
            "max_completion_tokens": max_completion_tokens,
        }
        _, _, image_b64 = img_url.partition(",")
        print("[gpt-ocr] payload.model =", payload.get("model"), flush=True)
        print("[gpt-ocr] messages.count =", len(payload.get("messages", [])), flush=True)
        print("[gpt-ocr] image_b64_chars =", len(image_b64), flush=True)

        try:
            raw = chat_completions(
                url=api_url,
                api_key=api_key,
                model=get_model(),
                messages=messages,
                timeout_sec=get_timeout_sec(),
                max_completion_tokens=max_completion_tokens,
            )
        except ChatCompletionsHttpError as e:
            _log(f"API HTTP {e.status_code} | detail={e.detail!r}")
            alt = "system" if role == "developer" else "developer"
            hint = None
            if e.status_code == 400:
                hint = (
                    "이미지·역할·페이로드 문제 가능. GMS는 큰 data URL에서 오류 메시지가 "
                    "'Model not found'처럼 보이기도 함. GPT_OCR_UPSTREAM_* 로 축소를 강화하거나 "
                    f"GPT_OCR_INSTRUCTION_ROLE={alt} 로 시도하세요."
                )
            raise ChatCompletionsHttpError(
                e.status_code,
                {"upstream": e.detail, "hint": hint, "request_role": role},
                debug={
                    "image_b64_chars": len(image_b64),
                    "model": payload.get("model"),
                },
            ) from e

        usage = raw.get("usage")
        if usage is not None:
            _log(f"응답 usage={usage}")

        choices = raw.get("choices") or []
        if not choices:
            _log(f"오류: choices 비어 있음 | raw keys={list(raw.keys())}")
            raise RuntimeError(f"unexpected API response: {raw!r}")

        content = choices[0].get("message", {}).get("content")
        if not content:
            _log(f"오류: message.content 없음 | choice0={choices[0]!r}")
            raise RuntimeError(f"no message content in response: {raw!r}")

        text_out = content if isinstance(content, str) else str(content)
        _log(f"모델 텍스트 응답 길이={len(text_out)}자 (앞 240자) {text_out[:240]!r}")

        extracted = _extract_json_object(text_out)
        _log(f"파싱 JSON 키={list(extracted.keys())} 원본 bank_name={extracted.get('bank_name')!r} "
             f"원본 account_number={extracted.get('account_number')!r}")

        bank_raw = extracted.get("bank_name")
        bank_name = resolve_bank_name(bank_raw) if bank_raw else None

        full_text = extracted.get("full_text") or ""
        if not isinstance(full_text, str):
            full_text = str(full_text)

        lines = [ln.strip() for ln in full_text.splitlines() if ln.strip()]
        items: List[Dict[str, Any]] = [
            {"text": ln, "score": 1.0, "box": _GPT_LINE_PLACEHOLDER_BOX} for ln in lines
        ] if lines else []

        account_gpt = _normalize_account_digits(extracted.get("account_number"))
        account_number, account_source = _merge_gpt_account_with_postprocess(
            bank_name, account_gpt, items, full_text.strip()
        )
        pattern_info = get_pattern_match_info(bank_name, account_number)

        if bank_raw is not None and bank_name != bank_raw:
            _log(f"은행명 정규화 | {bank_raw!r} -> {bank_name!r}")
        if account_source != "gpt_only":
            _log(
                f"계좌 보정({account_source}) | gpt={account_gpt!r} -> 최종={account_number!r}"
            )
        _log(
            f"후처리 결과 | bank_name={bank_name!r} account_number={account_number!r} "
            f"pattern_matched={pattern_info.get('matched')} best_score={pattern_info.get('best_score')} "
            f"matched_rules={pattern_info.get('matched_rules')}"
        )

        parsed: Dict[str, Any] = {
            "bank_name": bank_name,
            "account_number": account_number,
            "pattern_info": pattern_info,
        }

        _log(
            f"완료 | full_text 줄 수={len(lines)} items={len(items)}"
        )

        return {
            "items": items,
            "full_text": full_text.strip(),
            "parsed": parsed,
            "meta": {
                "engine": self.name,
                "model": get_model(),
                "preprocess_mode": preprocess_mode,
                "api_url": get_api_url(),
                "usage": raw.get("usage"),
                "account_merge": account_source,
                "account_gpt_raw": account_gpt,
            },
        }
