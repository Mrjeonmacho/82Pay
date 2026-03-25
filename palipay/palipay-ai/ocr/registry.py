from threading import Lock
from typing import Dict, Type

from gpt_ocr.engine import GptOCREngine

from .base import OCREngine
from .paddle_engine import PaddleOCREngine

_ENGINE_CLASSES: Dict[str, Type[OCREngine]] = {
    "paddle": PaddleOCREngine,
    "gpt": GptOCREngine,
    # "clova": ClovaOCREngine,
}

ENGINES: tuple[str, ...] = tuple(sorted(_ENGINE_CLASSES.keys()))

_instances: Dict[str, OCREngine] = {}
_lock = Lock()


def get_engine(name: str) -> OCREngine:
    if name not in _ENGINE_CLASSES:
        raise ValueError(f"Unknown engine: {name}")
    if name not in _instances:
        with _lock:
            if name not in _instances:
                _instances[name] = _ENGINE_CLASSES[name]()
    return _instances[name]
