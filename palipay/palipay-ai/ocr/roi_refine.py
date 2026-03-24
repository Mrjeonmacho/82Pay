from typing import Any, Dict, List, Optional, Tuple
import numpy as np


def _numeric_like_score(text: str) -> float:
    if not text:
        return 0.0
    allowed = set("0123456789-|/IlOoO")
    kept = sum(1 for ch in text if ch in allowed)
    return kept / max(len(text), 1)


def _box_bounds(box: List[List[float]]) -> Tuple[int, int, int, int]:
    xs = [int(p[0]) for p in box]
    ys = [int(p[1]) for p in box]
    return min(xs), min(ys), max(xs), max(ys)


def _box_center_y(box: List[List[float]]) -> float:
    ys = [p[1] for p in box]
    return (min(ys) + max(ys)) / 2.0


def _box_height(box: List[List[float]]) -> float:
    ys = [p[1] for p in box]
    return max(ys) - min(ys)


def build_numeric_roi(
    img_bgr: np.ndarray,
    items: List[Dict[str, Any]],
    min_numeric_score: float = 0.6,
) -> Optional[np.ndarray]:
    numeric_items = [
        item for item in items
        if _numeric_like_score(item.get("text", "")) >= min_numeric_score
    ]

    if not numeric_items:
        return None

    # 숫자 아이템들의 평균 높이
    heights = [_box_height(item["box"]) for item in numeric_items]
    avg_h = float(np.mean(heights)) if heights else 20.0

    # 숫자 아이템 y 중심 평균
    numeric_y_centers = [_box_center_y(item["box"]) for item in numeric_items]
    target_y = float(np.mean(numeric_y_centers))

    # 같은 줄(row)에 있는 아이템까지 포함
    row_items: List[Dict[str, Any]] = []
    y_threshold = max(12.0, avg_h * 0.8)

    for item in items:
        cy = _box_center_y(item["box"])
        if abs(cy - target_y) <= y_threshold:
            row_items.append(item)

    if not row_items:
        row_items = numeric_items

    x1_list = []
    y1_list = []
    x2_list = []
    y2_list = []

    for item in row_items:
        x1, y1, x2, y2 = _box_bounds(item["box"])
        x1_list.append(x1)
        y1_list.append(y1)
        x2_list.append(x2)
        y2_list.append(y2)

    # 좌측을 훨씬 넓게
    left_pad = max(30, int(avg_h * 2.0))
    right_pad = max(16, int(avg_h * 0.8))
    top_pad = max(8, int(avg_h * 0.4))
    bottom_pad = max(8, int(avg_h * 0.4))

    x1 = max(0, min(x1_list) - left_pad)
    y1 = max(0, min(y1_list) - top_pad)
    x2 = min(img_bgr.shape[1], max(x2_list) + right_pad)
    y2 = min(img_bgr.shape[0], max(y2_list) + bottom_pad)

    if x2 <= x1 or y2 <= y1:
        return None

    return img_bgr[y1:y2, x1:x2].copy()