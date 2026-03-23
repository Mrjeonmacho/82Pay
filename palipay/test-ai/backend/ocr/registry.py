from .paddle_engine import PaddleOCREngine
from .easy_engine import EasyOCREngine

_ENGINES = {
    "paddle": PaddleOCREngine(),
    "easy": EasyOCREngine(),
    # "clova": ClovaOCREngine(),  # 나중에 추가
}

def get_engine(name: str):
    if name not in _ENGINES:
        raise ValueError(f"Unknown engine: {name}")
    return _ENGINES[name]