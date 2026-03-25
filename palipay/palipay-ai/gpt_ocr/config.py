"""GPT OCR 설정은 전부 os.environ 에서 읽는다. 로컬은 backend/.env, 배포는 플랫폼 credential/환경변수."""
import os

DEFAULT_CHAT_COMPLETIONS_URL = (
    "https://gms.ssafy.io/gmsapi/api.openai.com/v1/chat/completions"
)
DEFAULT_MODEL = "gpt-5.2"
DEFAULT_TIMEOUT_SEC = 60.0
DEFAULT_INSTRUCTION_ROLE = "developer"


def get_api_url() -> str:
    return os.environ.get("GPT_OCR_API_URL", DEFAULT_CHAT_COMPLETIONS_URL).strip()


def get_api_key() -> str:
    return (
        os.environ.get("GPT_OCR_API_KEY") or os.environ.get("GMS_KEY") or ""
    ).strip()


def get_model() -> str:
    return os.environ.get("GPT_OCR_MODEL", DEFAULT_MODEL).strip()


def get_timeout_sec() -> float:
    raw = os.environ.get("GPT_OCR_TIMEOUT_SEC", "")
    if raw:
        try:
            return float(raw)
        except ValueError:
            pass
    return DEFAULT_TIMEOUT_SEC


def get_instruction_role() -> str:
    """GMS 예시는 developer. 필요 시 system."""
    return os.environ.get("GPT_OCR_INSTRUCTION_ROLE", DEFAULT_INSTRUCTION_ROLE).strip()


def get_image_max_side() -> int:
    raw = os.environ.get("GPT_OCR_IMAGE_MAX_SIDE", "2048")
    try:
        return max(640, min(4096, int(raw)))
    except ValueError:
        return 2048
