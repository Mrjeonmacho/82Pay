from abc import ABC, abstractmethod
from typing import Any, Dict, List, Optional

class OCREngine(ABC):
    name: str

    @abstractmethod
    def recognize(self, img_bgr, *, preprocess_mode: str = "basic") -> Dict[str, Any]:
        """
        img_bgr: OpenCV BGR numpy array
        return: { items: [{text, score, box}], meta: {...} }
        """
        raise NotImplementedError