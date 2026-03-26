"""GPT OCR 설정은 전부 os.environ 에서 읽는다. 로컬은 backend/.env, 배포는 플랫폼 credential/환경변수."""
import os

DEFAULT_CHAT_COMPLETIONS_URL = (
    "https://gms.ssafy.io/gmsapi/api.openai.com/v1/chat/completions"
)
DEFAULT_MODEL = "gpt-5.2"
DEFAULT_TIMEOUT_SEC = 60.0
DEFAULT_INSTRUCTION_ROLE = "developer"
DEFAULT_MAX_COMPLETION_TOKENS = 4096
# GMS 프록시: 큰 data URL 요청이 오해된 400(예: Model not found)을 유발할 수 있어 별도 한도 사용
DEFAULT_GPT_UPSTREAM_MAX_SIDE = 1024
DEFAULT_GPT_UPSTREAM_JPEG_QUALITY = 75
DEFAULT_GPT_UPSTREAM_FALLBACK_MAX_SIDE = 900
DEFAULT_GPT_UPSTREAM_FALLBACK_JPEG_QUALITY = 70
DEFAULT_GPT_UPSTREAM_B64_THRESHOLD = 120_000


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


def get_max_completion_tokens() -> int:
    raw = (
        os.environ.get("GPT_OCR_MAX_COMPLETION_TOKENS")
        or os.environ.get("GPT_OCR_MAX_TOKENS")
        or ""
    )
    if raw:
        try:
            v = int(raw)
            return max(1, min(200_000, v))
        except ValueError:
            pass
    return DEFAULT_MAX_COMPLETION_TOKENS


def get_gpt_upstream_max_side() -> int:
    raw = os.environ.get("GPT_OCR_UPSTREAM_MAX_SIDE", "")
    if raw:
        try:
            return max(256, min(4096, int(raw)))
        except ValueError:
            pass
    return DEFAULT_GPT_UPSTREAM_MAX_SIDE


def get_gpt_upstream_jpeg_quality() -> int:
    raw = os.environ.get("GPT_OCR_UPSTREAM_JPEG_QUALITY", "")
    if raw:
        try:
            return max(40, min(95, int(raw)))
        except ValueError:
            pass
    return DEFAULT_GPT_UPSTREAM_JPEG_QUALITY


def get_gpt_upstream_fallback_max_side() -> int:
    raw = os.environ.get("GPT_OCR_UPSTREAM_FALLBACK_MAX_SIDE", "")
    if raw:
        try:
            return max(256, min(4096, int(raw)))
        except ValueError:
            pass
    return DEFAULT_GPT_UPSTREAM_FALLBACK_MAX_SIDE


def get_gpt_upstream_fallback_jpeg_quality() -> int:
    raw = os.environ.get("GPT_OCR_UPSTREAM_FALLBACK_JPEG_QUALITY", "")
    if raw:
        try:
            return max(40, min(95, int(raw)))
        except ValueError:
            pass
    return DEFAULT_GPT_UPSTREAM_FALLBACK_JPEG_QUALITY


def get_gpt_upstream_b64_threshold() -> int:
    raw = os.environ.get("GPT_OCR_UPSTREAM_B64_THRESHOLD", "")
    if raw:
        try:
            return max(10_000, min(500_000, int(raw)))
        except ValueError:
            pass
    return DEFAULT_GPT_UPSTREAM_B64_THRESHOLD


def get_instruction_role() -> str:
    """GMS 예시는 developer. 필요 시 system."""
    return os.environ.get("GPT_OCR_INSTRUCTION_ROLE", DEFAULT_INSTRUCTION_ROLE).strip()


def get_image_max_side() -> int:
    raw = os.environ.get("GPT_OCR_IMAGE_MAX_SIDE", "2048")
    try:
        return max(640, min(4096, int(raw)))
    except ValueError:
        return 2048
