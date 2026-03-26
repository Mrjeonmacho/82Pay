"""GMS 업스트림 전송용 이미지 축소·JPEG 재인코딩 (PIL)."""

from __future__ import annotations

import io
from typing import Any, Dict, Tuple

import cv2
from PIL import Image


def encode_bgr_for_gpt_upstream(
    img_bgr: Any,
    *,
    max_side: int,
    jpeg_quality: int,
) -> Tuple[bytes, Dict[str, Any]]:
    """BGR ndarray → RGB PIL → 긴 변 max_side 이하 스케일 → JPEG."""
    orig_h, orig_w = int(img_bgr.shape[0]), int(img_bgr.shape[1])
    rgb = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)
    img = Image.fromarray(rgb)
    w, h = img.size
    longest = max(w, h)
    resized = False
    if longest > max_side:
        ratio = max_side / float(longest)
        nw, nh = int(w * ratio), int(h * ratio)
        img = img.resize((nw, nh), Image.Resampling.LANCZOS)
        resized = True
    buf = io.BytesIO()
    img.save(buf, format="JPEG", quality=jpeg_quality, optimize=True)
    data = buf.getvalue()
    out_w, out_h = img.size
    return data, {
        "orig_wh": (orig_w, orig_h),
        "out_wh": (out_w, out_h),
        "max_side_cap": max_side,
        "jpeg_quality": jpeg_quality,
        "resized": resized,
        "jpeg_bytes": len(data),
    }
