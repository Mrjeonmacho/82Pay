from __future__ import annotations

import io

import cv2
import numpy as np
from fastapi import APIRouter, File, HTTPException, Query, UploadFile
from PIL import Image

from gpt_ocr.client import ChatCompletionsHttpError
from ocr.registry import get_engine

router = APIRouter()


@router.post("/api/ocr")
async def ocr_image(
    file: UploadFile = File(...),
    engine: str = Query(
        #"paddle",
        "gpt",
        description="paddle (로컬 PaddleOCR) | gpt (GMS Chat Completions 비전)",
    ),
    preprocess_mode: str = Query("basic", description="none | basic | strong (gpt는 시그니처 호환만)"),
):
    content = await file.read()

    img = Image.open(io.BytesIO(content)).convert("RGB")
    img_rgb = np.array(img)
    img_bgr = cv2.cvtColor(img_rgb, cv2.COLOR_RGB2BGR)

    try:
        ocr_engine = get_engine(engine)
        result = ocr_engine.recognize(img_bgr, preprocess_mode=preprocess_mode)
    except ChatCompletionsHttpError as e:
        raise HTTPException(
            status_code=502,
            detail={
                "message": "GMS Chat Completions 호출 실패",
                "upstream_status": e.status_code,
                "upstream": e.detail,
            },
        ) from e
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e)) from e

    return {
        "full_text": result["full_text"],
        "parsed": result["parsed"],
        "meta": result["meta"],
    }
