from __future__ import annotations

import base64
import json
import re
from typing import Any, Dict, List, Optional

import cv2

from ocr.bank_patterns import get_pattern_match_info, resolve_bank_name
from ocr.base import OCREngine

from .client import ChatCompletionsHttpError, chat_completions
from .config import (
    get_api_key,
    get_api_url,
    get_image_max_side,
    get_instruction_role,
    get_model,
    get_timeout_sec,
)
from .prompts import build_developer_prompt


def _bgr_to_data_url_jpeg(img_bgr: Any) -> str:
    max_side = get_image_max_side()
    h, w = img_bgr.shape[:2]
    if max(h, w) > max_side:
        scale = max_side / float(max(h, w))
        img_bgr = cv2.resize(
            img_bgr,
            (int(w * scale), int(h * scale)),
            interpolation=cv2.INTER_AREA,
        )
    ok, buf = cv2.imencode(
        ".jpg",
        img_bgr,
        [int(cv2.IMWRITE_JPEG_QUALITY), 88],
    )
    if not ok:
        raise RuntimeError("failed to encode image as JPEG")
    b64 = base64.b64encode(buf.tobytes()).decode("ascii")
    return f"data:image/jpeg;base64,{b64}"


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
        _ = preprocess_mode

        api_key = get_api_key()
        if not api_key:
            raise ValueError(
                "GPT OCR API 키가 없습니다. 환경변수 GPT_OCR_API_KEY 또는 GMS_KEY를 설정하세요. "
                "(로컬: backend/.env, 배포: 플랫폼 credential)"
            )

        img_url = _bgr_to_data_url_jpeg(img_bgr)
        role = get_instruction_role()
        messages = [
            {"role": role, "content": build_developer_prompt()},
            {"role": "user", "content": _message_content_with_image(img_url)},
        ]

        try:
            raw = chat_completions(
                url=get_api_url(),
                api_key=api_key,
                model=get_model(),
                messages=messages,
                timeout_sec=get_timeout_sec(),
            )
        except ChatCompletionsHttpError as e:
            alt = "system" if role == "developer" else "developer"
            hint = None
            if e.status_code == 400:
                hint = (
                    f"역할/페이로드 문제일 수 있음. GPT_OCR_INSTRUCTION_ROLE={alt} 로 시도하거나 "
                    "upstream 메시지를 확인하세요."
                )
            raise ChatCompletionsHttpError(
                e.status_code,
                {"upstream": e.detail, "hint": hint, "request_role": role},
            ) from e

        choices = raw.get("choices") or []
        if not choices:
            raise RuntimeError(f"unexpected API response: {raw!r}")

        content = choices[0].get("message", {}).get("content")
        if not content:
            raise RuntimeError(f"no message content in response: {raw!r}")

        extracted = _extract_json_object(content if isinstance(content, str) else str(content))

        bank_raw = extracted.get("bank_name")
        bank_name = resolve_bank_name(bank_raw) if bank_raw else None

        account_number = _normalize_account_digits(extracted.get("account_number"))
        pattern_info = get_pattern_match_info(bank_name, account_number)

        full_text = extracted.get("full_text") or ""
        if not isinstance(full_text, str):
            full_text = str(full_text)

        lines = [ln.strip() for ln in full_text.splitlines() if ln.strip()]
        items: List[Dict[str, Any]] = [
            {"text": ln, "score": 1.0, "box": []} for ln in lines
        ] if lines else []

        parsed: Dict[str, Any] = {
            "bank_name": bank_name,
            "account_number": account_number,
            "pattern_info": pattern_info,
        }

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
            },
        }
