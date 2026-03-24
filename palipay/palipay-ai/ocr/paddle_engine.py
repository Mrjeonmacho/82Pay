from typing import Any, Dict, List
import cv2
from paddleocr import PaddleOCR

from .base import OCREngine
from .preprocess import preprocess
from .postprocess import parse_ocr_fields
from .roi_refine import build_numeric_roi



def _pick_better_result(primary: Dict[str, Any], secondary: Dict[str, Any]) -> Dict[str, Any]:
    p = primary.get("parsed", {})
    s = secondary.get("parsed", {})

    p_acc = p.get("account_number")
    s_acc = s.get("account_number")

    if not p_acc and s_acc:
        return secondary
    if p_acc and not s_acc:
        return primary
    if not p_acc and not s_acc:
        return primary

    p_info = p.get("pattern_info", {})
    s_info = s.get("pattern_info", {})

    p_score = float(p_info.get("best_score", 0))
    s_score = float(s_info.get("best_score", 0))

    if s_score > p_score:
        return secondary
    if p_score > s_score:
        return primary

    p_digits = len("".join(ch for ch in p_acc if ch.isdigit()))
    s_digits = len("".join(ch for ch in s_acc if ch.isdigit()))

    if 9 <= s_digits <= 16 and not (9 <= p_digits <= 16):
        return secondary
    if 9 <= p_digits <= 16 and not (9 <= s_digits <= 16):
        return primary

    return secondary


class PaddleOCREngine(OCREngine):
    name = "paddle"

    def __init__(self):
        self.ocr = PaddleOCR(
            lang="korean",
        )

    def _run_ocr(self, img_bgr, preprocess_mode: str) -> Dict[str, Any]:
        processed = preprocess(img_bgr, preprocess_mode)
        img_rgb = cv2.cvtColor(processed, cv2.COLOR_BGR2RGB)
        result = self.ocr.ocr(img_rgb, cls=True)

        items: List[Dict[str, Any]] = []
        if result and len(result) > 0 and result[0]:
            for line in result[0]:
                box = line[0]
                text, score = line[1][0], float(line[1][1])
                items.append({
                    "text": text,
                    "score": score,
                    "box": box,
                })

        full_text = "\n".join(item["text"] for item in items)
        parsed = parse_ocr_fields(items, full_text)

        return {
            "items": items,
            "full_text": full_text,
            "parsed": parsed,
            "meta": {
                "engine": self.name,
                "preprocess_mode": preprocess_mode,
            },
        }

    def recognize(self, img_bgr, *, preprocess_mode: str = "basic") -> Dict[str, Any]:
        primary = self._run_ocr(img_bgr, preprocess_mode)
        primary["meta"]["retried_numeric_roi"] = False

        roi = build_numeric_roi(img_bgr, primary["items"])
        if roi is None:
            return primary

        secondary = self._run_ocr(roi, "numeric")
        better = _pick_better_result(primary, secondary)

        better["meta"]["retried_numeric_roi"] = True
        better["meta"]["primary_parsed"] = primary["parsed"]
        better["meta"]["secondary_parsed"] = secondary["parsed"]

        print("primary full_text =", primary["full_text"])
        print("secondary full_text =", secondary["full_text"])
        print("primary parsed =", primary["parsed"])
        print("secondary parsed =", secondary["parsed"])

        return better