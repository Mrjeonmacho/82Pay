from __future__ import annotations

import time
from typing import Any, Dict, List, Optional

import httpx


class ChatCompletionsHttpError(Exception):
    """Chat Completions 호출이 4xx/5xx일 때 upstream 상태·본문을 담는다."""

    def __init__(
        self,
        status_code: int,
        detail: Any,
        *,
        debug: Optional[Dict[str, Any]] = None,
    ):
        self.status_code = status_code
        self.detail = detail
        self.debug = debug if debug is not None else {}
        super().__init__(str(detail))


def chat_completions(
    *,
    url: str,
    api_key: str,
    model: str,
    messages: List[Dict[str, Any]],
    timeout_sec: float,
    max_completion_tokens: int,
) -> Dict[str, Any]:
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}",
    }
    body: Dict[str, Any] = {
        "model": model,
        "messages": messages,
        "max_completion_tokens": max_completion_tokens,
    }
    with httpx.Client(timeout=timeout_sec) as client:
        t0 = time.perf_counter()
        r = client.post(url, headers=headers, json=body)
        elapsed = time.perf_counter() - t0
        print(
            f"[gpt-ocr] HTTP {r.status_code} elapsed={elapsed:.2f}s",
            flush=True,
        )
        if r.status_code >= 400:
            try:
                detail = r.json()
            except Exception:
                detail = r.text.strip() or r.reason_phrase
            print(f"[gpt-ocr] HTTP 오류 본문(일부)={str(detail)[:500]!r}", flush=True)
            raise ChatCompletionsHttpError(r.status_code, detail)
        return r.json()
