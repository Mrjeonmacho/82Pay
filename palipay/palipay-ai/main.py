from pathlib import Path

from dotenv import load_dotenv

# 다른 모듈 import 전에 .env 로드
# override=True: 셸에 빈 GPT_OCR_API_KEY=만 있어도 .env 값이 적용되게 함
_backend_dir = Path(__file__).resolve().parent
_root_dir = _backend_dir.parent
for _env_path in (_backend_dir / ".env", _root_dir / ".env"):
    if _env_path.is_file():
        _ok = load_dotenv(_env_path, override=True, encoding="utf-8-sig")
        print(f"[ocr] dotenv loaded {_env_path} (ok={_ok})")
    else:
        print(f"[ocr] dotenv skip (없음) {_env_path}")

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from api.routes_ocr import router as ocr_router
from ocr.registry import ENGINES

app = FastAPI()


@app.on_event("startup")
def _log_ocr_engines() -> None:
    import os

    print("[ocr] registered engines:", list(ENGINES))
    has_key = bool(
        (os.environ.get("GPT_OCR_API_KEY") or "").strip()
        or (os.environ.get("GMS_KEY") or "").strip()
    )
    print(
        "[ocr] GPT credential:",
        "OK (GPT_OCR_API_KEY 또는 GMS_KEY 있음)" if has_key else "없음",
    )
    if not has_key:
        print(
            "[ocr] 해결: backend/.env.example 을 backend/.env 로 복사하고 "
            "GPT_OCR_API_KEY=실제키 또는 GMS_KEY=실제키 한 줄을 넣은 뒤 서버 재시작"
        )


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(ocr_router)
