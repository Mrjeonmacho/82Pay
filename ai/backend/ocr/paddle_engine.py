from typing import Any, Dict, List
import cv2
import numpy as np
from paddleocr import PaddleOCR

from .base import OCREngine
from .preprocess import preprocess

class PaddleOCREngine(OCREngine):
    name = "paddle"

    def __init__(self):
        # self.ocr = PaddleOCR(
        #     use_angle_cls=True, 
        #     lang="korean",
        #     rec_algorithm="SVTR_LCNet", 
        #     rec_char_type="ch",
        #     #rec_char_dict_path="./ocr_assets/char_dict.txt",
        #     rec_model_dir="./ocr/rec_model",
        #     cls_model_dir="./ocr/cls_model",
        #     det_model_dir="./ocr/det_model",
        # )
        self.ocr = PaddleOCR(
            lang="korean",
        )

    def recognize(self, img_bgr, *, preprocess_mode: str = "basic") -> Dict[str, Any]:
        img_bgr = preprocess(img_bgr, preprocess_mode)
        #img_bgr = preprocess(img_bgr, "none")

        # PaddleOCR는 RGB 입력을 권장
        img_rgb = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)
        result = self.ocr.ocr(img_rgb, cls=True)

        items: List[Dict[str, Any]] = []
        if result and len(result) > 0:
            for line in result[0]:
                box = line[0]
                text, score = line[1][0], float(line[1][1])
                items.append({"text": text, "score": score, "box": box})

        full_text = "\n".join([item["text"] for item in items])

        return {
            "items": items, 
            "full_text": full_text,
            "meta": {"engine": self.name, "preprocess_mode": preprocess_mode}
            }

            