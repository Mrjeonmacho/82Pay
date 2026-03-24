from fastapi import APIRouter, UploadFile, File, Query
from PIL import Image
import numpy as np
import cv2
import io

from ocr.registry import get_engine

router = APIRouter()

@router.post("/api/ocr")
async def ocr_image(
    file: UploadFile = File(...),
    engine: str = Query("paddle", description="paddle | easy | clova(추후)"),
    preprocess_mode: str = Query("basic", description="none | basic | strong"),
):
    content = await file.read()

    # PIL -> numpy(RGB) -> OpenCV(BGR)
    img = Image.open(io.BytesIO(content)).convert("RGB")
    img_rgb = np.array(img)
    img_bgr = cv2.cvtColor(img_rgb, cv2.COLOR_RGB2BGR)

    ocr_engine = get_engine(engine)
    result = ocr_engine.recognize(img_bgr, preprocess_mode=preprocess_mode)

    return {
        "full_text": result["full_text"],
        "parsed": result["parsed"],
        "meta": result["meta"],
    }