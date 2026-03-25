from __future__ import annotations

from typing import Any, Dict, List

import httpx


class ChatCompletionsHttpError(Exception):
    """Chat Completions 호출이 4xx/5xx일 때 upstream 상태·본문을 담는다."""

    def __init__(self, status_code: int, detail: Any):
        self.status_code = status_code
        self.detail = detail
        super().__init__(str(detail))


def chat_completions(
    *,
    url: str,
    api_key: str,
    model: str,
    messages: List[Dict[str, Any]],
    timeout_sec: float,
) -> Dict[str, Any]:
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}",
    }
    body: Dict[str, Any] = {
        "model": model,
        "messages": messages,
    }
    with httpx.Client(timeout=timeout_sec) as client:
        r = client.post(url, headers=headers, json=body)
        if r.status_code >= 400:
            try:
                detail = r.json()
            except Exception:
                detail = r.text.strip() or r.reason_phrase
            raise ChatCompletionsHttpError(r.status_code, detail)
        return r.json()
