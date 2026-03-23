from typing import Any, Dict, List
import cv2
import easyocr

from .base import OCREngine
from .preprocess import preprocess

class EasyOCREngine(OCREngine):
    name = "easy"

    def __init__(self):
        self.reader = easyocr.Reader(['ko', 'en'])

    def recognize(self, img_bgr, *, preprocess_mode: str = "basic") -> Dict[str, Any]:
        img_bgr = preprocess(img_bgr, preprocess_mode)

        # EasyOCR works well with RGB
        img_rgb = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)
        result = self.reader.readtext(img_rgb)

        items: List[Dict[str, Any]] = []
        if result and len(result) > 0:
            for line in result:
                box = line[0]
                text = line[1]
                score = float(line[2])
                
                # convert box points (numpy types to native python floats if necessary)
                # Ensure they are lists of floats to be JSON serializable
                box_serializable = [[float(v) for v in pt] for pt in box]
                
                items.append({"text": text, "score": score, "box": box_serializable})

        full_text = "\n".join([item["text"] for item in items])

        return {
            "items": items, 
            "full_text": full_text,
            "meta": {"engine": self.name, "preprocess_mode": preprocess_mode}
        }
