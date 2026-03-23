from typing import Any, Dict, List, Optional
import re
import cv2
import difflib
from paddleocr import PaddleOCR

from .base import OCREngine
from .preprocess import preprocess

# =========================
# 텍스트 정리 유틸
# =========================
# 은행 리스트 (서비스용)
VALID_BANK_NAMES = [
    "NH농협은행", "우리은행", "하나은행", "신한은행", "KB국민은행",
    "IBK기업은행", "카카오뱅크", "토스뱅크", "케이뱅크", "sc제일은행"
]

# 계좌번호 숫자 길이
ACCOUNT_NUMBER_LENGTH = 13

# 특수문자 제거
def _clean_text(text: str) -> str:
    text = text.replace(':', '')
    text = text.replace('/', '')
    text = text.replace('.', '')
    return text

# 숫자만 추출
def _extract_digits(text: str) -> str:
    return re.sub(r'[^0-9]', '', text)

# box를 사각형 좌표로 바꾸는 함수
def _box_to_rect(box):
    xs = [pt[0] for pt in box]
    ys = [pt[1] for pt in box]
    return min(xs), min(ys), max(xs), max(ys)

# =========================
# 문맥 키워드
# =========================
def _normalize_bank_text(text: str) -> str:
    return text.strip().replace(" ", "").replace("(", "").replace(")", "")


def _extract_bank_name(items: List[Dict[str, Any]]) -> Optional[str]:
    best_bank = None
    best_score = 0.0

    for item in items:
        text = item["text"]
        norm = _normalize_bank_text(text)

        if not norm:
            continue

        for bank in VALID_BANK_NAMES:
            ratio = difflib.SequenceMatcher(
                None,
                norm,
                _normalize_bank_text(bank)
            ).ratio()

            if ratio > best_score and ratio >= 0.5:
                best_score = ratio
                best_bank = bank

    return best_bank

# 강한 계좌 문맥: 은행명
ACCOUNT_BANK_KEYWORDS = [
    "농협", "우리", "하나", "신한", "국민", "기업", "카카오", "토스", "케이", "sc제일",
    "우리은행", "하나은행", "신한은행", "국민은행", "기업은행", "카카오뱅크", "토스뱅크",
    "농협은행", "NH농협은행", "KB국민은행", "IBK기업은행", "케이뱅크", "sc제일은행",
]

# 약한 계좌 문맥: 점수 약하게
ACCOUNT_WEAK_KEYWORDS = [
    "계좌", "계좌이체", "입금",
]

PHONE_CONTEXT_KEYWORDS = [
    "전화", "문의", "연락처", "tel", "t.", "핸드폰", "휴대폰", "T.",
]

# =========================
# 숫자 후보 / 그룹화
# =========================
def _normalize_account_length(digits: str) -> Optional[str]:
    if not digits:
        return None

    # 길이 초과 → 뒤 자르기 (핵심 해결)
    if len(digits) > ACCOUNT_NUMBER_LENGTH:
        return digits[:ACCOUNT_NUMBER_LENGTH]

    # 길이 부족 → 실패
    if len(digits) < ACCOUNT_NUMBER_LENGTH:
        return None

    return digits

# 숫자 후보 판별 함수
def _is_numeric_candidate(text: str, score: float) -> bool:
    # 짧은 숫자 조각(예: 마지막 1, 73)도 살려야 하므로 느슨하게
    if score < 0.4:
        return False

    digit_count = sum(ch.isdigit() for ch in text)
    hyphen_count = text.count("-")

    # 숫자가 충분히 많거나 하이픈이 있으면 후보
    return digit_count >= 1 or hyphen_count >= 1

# 같은 줄 숫자 박스 묶기
def _group_numeric_items(items: List[Dict[str, Any]]):
    numeric_items = []

    for item in items:
        if _is_numeric_candidate(item["text"], item["score"]):
            x1, y1, x2, y2 = _box_to_rect(item["box"])
            numeric_items.append({
                **item,
                "rect": (x1, y1, x2, y2),
                "cx": (x1 + x2) / 2,
                "cy": (y1 + y2) / 2,
            })
    # 먼저 y축 기준으로 정렬
    numeric_items.sort(key=lambda x: x["cy"])

    groups = []
    for item in numeric_items:
        placed = False
        for group in groups:
            # 같은 줄 판단: 중심 y 차이가 작으면 같은 그룹
            if abs(group["cy"] - item["cy"]) < 60:
                group["items"].append(item)
                group["cy"] = sum(i["cy"] for i in group["items"]) / len(group["items"])
                placed = True
                break

        if not placed:
            groups.append({
                "cy": item["cy"],
                "items": [item]
            })
        
    # [중요] 같은 줄 안에서는 좌->우 순서 정렬
    for group in groups:
        group["items"].sort(key=lambda x: x["rect"][0])

    return groups

# 줄 그룹을 숫자 문자열로 합치기
def _group_to_digits(group) -> str:
    texts = [item["text"] for item in group["items"]]
    merged_text = "".join(texts)
    cleaned = _clean_text(merged_text)
    return _extract_digits(cleaned)

# =========================
# 문맥 점수
# =========================
def _group_center(group):
    rects = [item["rect"] for item in group["items"]]
    x1 = min(r[0] for r in rects)
    y1 = min(r[1] for r in rects)
    x2 = max(r[2] for r in rects)
    y2 = max(r[3] for r in rects)
    return (x1 + x2) / 2, (y1 + y2) / 2


def _context_score(group, items: List[Dict[str, Any]]) -> float:
    gx, gy = _group_center(group)
    score = 0.0

    for item in items:
        text = item["text"]
        x1, y1, x2, y2 = _box_to_rect(item["box"])
        cx = (x1 + x2) / 2
        cy = (y1 + y2) / 2

        dx = abs(cx - gx)
        dy = abs(cy - gy)

        lowered = text.lower()

        same_line = dy < 45
        nearby_above = 45 <= dy < 110 and cy < gy
        nearby_below = 45 <= dy < 110 and cy > gy
        horizontally_close = dx < 350

        # 너무 멀면 무시
        if dx > 450 or dy > 120:
            continue

        # 1) 강한 계좌 문맥: 은행명
        for kw in ACCOUNT_BANK_KEYWORDS:
            if kw.lower() in lowered:
                if same_line and horizontally_close:
                    score += 120
                elif nearby_above and horizontally_close:
                    score += 70
                else:
                    score += 20

        # 2) 약한 계좌 문맥: 계좌/계좌이체/입금
        for kw in ACCOUNT_WEAK_KEYWORDS:
            if kw.lower() in lowered:
                if same_line and horizontally_close:
                    score += 35
                elif nearby_above and horizontally_close:
                    score += 20
                else:
                    score += 5

        # 3) 전화 문맥: 같은 줄이면 강한 감점
        for kw in PHONE_CONTEXT_KEYWORDS:
            if kw.lower() in lowered:
                if same_line and horizontally_close:
                    score -= 140
                elif nearby_above and horizontally_close:
                    score -= 70
                else:
                    score -= 25

    return score


# 줄 그룹 점수화
# 조각 하나하나 말고 줄 전체를 보고 판단
def _score_numeric_group(group, items: List[Dict[str, Any]]) -> float:
    texts = [item["text"] for item in group["items"]]
    merged_text = "".join(texts)

    digit_count = sum(ch.isdigit() for ch in merged_text)
    hyphen_count = merged_text.count("-")
    avg_score = sum(item["score"] for item in group["items"]) / len(group["items"])

    # 숫자가 많고, 하이픈이 적당히 있으면 가산점
    base_score = (digit_count * 10) + (hyphen_count * 15) + avg_score
    context = _context_score(group, items)

    return base_score + context

def _get_best_numeric_group(items: List[Dict[str, Any]]):
    groups = _group_numeric_items(items)
    if not groups:
        return None

    groups.sort(key=lambda g: _score_numeric_group(g, items), reverse=True)
    return groups[0]

# =========================
# crop 및 2차 OCR
# ========================

# 그룹 박스로 crop
def _crop_group_region(img_bgr, group, margin_x=30, margin_y=20):
    rects = [item["rect"] for item in group["items"]]

    x1 = min(r[0] for r in rects)
    y1 = min(r[1] for r in rects)
    x2 = max(r[2] for r in rects)
    y2 = max(r[3] for r in rects)

    h, w = img_bgr.shape[:2]

    x1 = max(0, int(x1 - margin_x))
    y1 = max(0, int(y1 - margin_y))
    x2 = min(w, int(x2 + margin_x))
    y2 = min(h, int(y2 + margin_y))

    # 잘못된 crop 방지
    if x2 <= x1 or y2 <= y1:
        return None

    crop = img_bgr[y1:y2, x1:x2]

    # 빈 이미지 방지
    if crop is None or crop.size == 0:
        return None

    return crop

# 1차 OCR 기준 줄 단위 계좌번호 후보
def _extract_account_number_from_groups(items: List[Dict[str, Any]]) -> Optional[str]:
    best_group = _get_best_numeric_group(items)
    if not best_group:
        return None

    digits = _group_to_digits(best_group)
    return _normalize_account_length(digits)

# =========================
# OCR 엔진
# =========================
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
        # 수정, OCR 엔진 두 개 만들기 - 전체용, 숫자용
        self.ocr_general = PaddleOCR(
            lang="korean",
            use_angle_cls=False,
        )

        # 숫자 전용
        self.ocr_numeric = PaddleOCR(
            lang="en",
            use_angle_cls = True,
        )

    # 숫자 crop에만 숫자 OCR 재실행
    def _run_numeric_ocr(self, crop_bgr):
        if crop_bgr is None or crop_bgr.size == 0:
            return ""

        crop_bgr = preprocess(crop_bgr, "none") 
        crop_rgb = cv2.cvtColor(crop_bgr, cv2.COLOR_BGR2RGB)
        result = self.ocr_numeric.ocr(crop_rgb, cls=True)

        texts = []
        if result and len(result) > 0 and result[0]:
            for line in result[0]:
                text = line[1][0]
                texts.append(text)

        return "".join(texts)

    def recognize(self, img_bgr, *, preprocess_mode: str = "basic") -> Dict[str, Any]:      
        # 1차: 전체 OCR
        img_bgr = preprocess(img_bgr, preprocess_mode)

        # PaddleOCR는 RGB 입력을 권장
        img_rgb = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)
        result = self.ocr_general.ocr(img_rgb, cls=False)

        items: List[Dict[str, Any]] = []
        if result and len(result) > 0 and result[0]:
            for line in result[0]:
                box = line[0]
                text, score = line[1][0], float(line[1][1])
                items.append({"text": text, "score": score, "box": box})

        full_text = "\n".join([item["text"] for item in items])

        # 은행명 추출
        bank_name = _extract_bank_name(items)        

        # 1차 후보
        account_number = _extract_account_number_from_groups(items)

        # 2차 refined: 같은 최고 그룹 하나만 재OCR
        best_group = _get_best_numeric_group(items)
        refined_account_number = None

        if best_group is not None:
            crop_bgr = _crop_group_region(img_bgr, best_group)

            if crop_bgr is not None:
                refined_text = self._run_numeric_ocr(crop_bgr)
                digits_only = _extract_digits(_clean_text(refined_text))
                
                refined_account_number = _normalize_account_length(digits_only)

        # fallback: refined가 없으면 1차 결과 사용
        final_account_number = refined_account_number or account_number

        return {
            "items": items, 
            "full_text": full_text,
            "bank_name": bank_name,
            "account_number": account_number,
            "refined_account_number": refined_account_number,
            "final_account_number": final_account_number,
            "meta": {"engine": self.name, "preprocess_mode": preprocess_mode}
            }

            