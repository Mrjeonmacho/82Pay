from __future__ import annotations

from dataclasses import dataclass
from difflib import SequenceMatcher
from typing import Any, Dict, List, Optional, Tuple
import re

from .bank_patterns import score_account_pattern, get_pattern_match_info


BANK_CANDIDATES = [
    "국민은행",
    "신한은행",
    "우리은행",
    "하나은행",
    "농협",
    "농협은행",
    "기업은행",
    "IBK기업은행",
    "새마을금고",
    "수협",
    "수협은행",
    "SC제일은행",
    "부산은행",
    "대구은행",
    "광주은행",
    "전북은행",
    "경남은행",
    "카카오뱅크",
    "케이뱅크",
    "토스뱅크",
    "우체국",
]

NOISE_WORDS = [
    "계좌이체",
    "계좌",
    "이체",
    "예금주",
    "입금",
    "출금",
    "송금",
    "받는분",
    "보내는분",
]


@dataclass
class OCRBoxItem:
    text: str
    score: float
    box: List[List[float]]

    @property
    def x_min(self) -> float:
        return min(p[0] for p in self.box)

    @property
    def x_max(self) -> float:
        return max(p[0] for p in self.box)

    @property
    def y_min(self) -> float:
        return min(p[1] for p in self.box)

    @property
    def y_max(self) -> float:
        return max(p[1] for p in self.box)

    @property
    def y_center(self) -> float:
        return (self.y_min + self.y_max) / 2.0

    @property
    def height(self) -> float:
        return self.y_max - self.y_min

    @property
    def width(self) -> float:
        return self.x_max - self.x_min


def _normalize_text(text: str) -> str:
    text = text.replace(" ", "")
    text = text.replace("\n", "")
    text = text.replace("\t", "")
    return text


def _clean_for_bank(text: str) -> str:
    text = _normalize_text(text)
    text = re.sub(r"[()（）\[\]{}<>]", "", text)
    return text


def _numeric_like_score(text: str) -> float:
    if not text:
        return 0.0

    allowed = set("0123456789-|/IlOoO")
    kept = sum(1 for ch in text if ch in allowed)
    return kept / max(len(text), 1)


def _normalize_account_chars(text: str, aggressive: bool = False) -> str:
    text = _normalize_text(text)

    mapping = {
        "O": "0",
        "o": "0",
        "I": "1",
        "l": "1",
        "|": "1",
    }

    if aggressive:
        mapping["/"] = "7"

    out = []
    for ch in text:
        out.append(mapping.get(ch, ch))
    text = "".join(out)

    text = re.sub(r"[^0-9\-]", "", text)
    text = re.sub(r"\-+", "-", text)
    text = text.strip("-")
    return text


def _digits_only(text: str) -> str:
    return re.sub(r"[^0-9]", "", text)


def _has_reasonable_account_shape(text: str) -> bool:
    digits = _digits_only(text)
    if len(digits) < 9:
        return False
    if len(digits) > 16:
        return False
    return True


def _merge_items_by_row(items: List[OCRBoxItem], y_threshold_ratio: float = 0.65) -> List[List[OCRBoxItem]]:
    if not items:
        return []

    sorted_items = sorted(items, key=lambda x: (x.y_center, x.x_min))
    rows: List[List[OCRBoxItem]] = []

    for item in sorted_items:
        placed = False

        for row in rows:
            avg_h = sum(r.height for r in row) / len(row)
            avg_y = sum(r.y_center for r in row) / len(row)
            threshold = max(8.0, avg_h * y_threshold_ratio)

            if abs(item.y_center - avg_y) <= threshold:
                row.append(item)
                placed = True
                break

        if not placed:
            rows.append([item])

    for row in rows:
        row.sort(key=lambda x: x.x_min)

    rows.sort(key=lambda row: min(x.y_center for x in row))
    return rows


def _join_row_text(row: List[OCRBoxItem]) -> str:
    return "".join(item.text for item in row)


def _build_row_candidates(items: List[OCRBoxItem]) -> List[str]:
    rows = _merge_items_by_row(items)
    if not rows:
        return []

    candidates: List[str] = []

    for row in rows:
        candidates.append(_join_row_text(row))

    for i in range(len(rows) - 1):
        merged = _join_row_text(rows[i]) + _join_row_text(rows[i + 1])
        candidates.append(merged)

    for i in range(len(rows) - 2):
        merged = _join_row_text(rows[i]) + _join_row_text(rows[i + 1]) + _join_row_text(rows[i + 2])
        candidates.append(merged)

    return candidates


def _similarity(a: str, b: str) -> float:
    return SequenceMatcher(None, a, b).ratio()


def _best_bank_by_substring(text: str) -> Optional[str]:
    for bank in sorted(BANK_CANDIDATES, key=len, reverse=True):
        if bank in text:
            return bank
    return None


def _best_bank_by_fuzzy(text: str) -> Tuple[Optional[str], float]:
    best_bank = None
    best_score = 0.0

    for bank in BANK_CANDIDATES:
        if len(text) < len(bank):
            score = _similarity(text, bank)
            if score > best_score:
                best_score = score
                best_bank = bank
            continue

        window = len(bank)
        for i in range(0, len(text) - window + 1):
            sub = text[i:i + window]
            score = _similarity(sub, bank)
            if score > best_score:
                best_score = score
                best_bank = bank

    return best_bank, best_score


def extract_bank_name(items_raw: List[Dict[str, Any]], full_text: str) -> Optional[str]:
    full = _clean_for_bank(full_text)

    direct = _best_bank_by_substring(full)
    if direct:
        return direct

    item_texts = [_clean_for_bank(i["text"]) for i in items_raw if i.get("text")]
    for t in item_texts:
        direct = _best_bank_by_substring(t)
        if direct:
            return direct

    text_for_match = full
    for noise in NOISE_WORDS:
        text_for_match = text_for_match.replace(noise, "")

    fuzzy_bank, fuzzy_score = _best_bank_by_fuzzy(text_for_match)
    if fuzzy_bank and fuzzy_score >= 0.72:
        return fuzzy_bank

    best_bank = None
    best_score = 0.0

    for t in item_texts:
        cleaned = t
        for noise in NOISE_WORDS:
            cleaned = cleaned.replace(noise, "")

        candidate_bank, candidate_score = _best_bank_by_fuzzy(cleaned)
        if candidate_bank and candidate_score > best_score:
            best_bank = candidate_bank
            best_score = candidate_score

    if best_bank and best_score >= 0.72:
        return best_bank

    return None


def _score_account_candidate(text: str, bank_name: Optional[str] = None) -> float:
    basic = _normalize_account_chars(text, aggressive=False)
    aggressive = _normalize_account_chars(text, aggressive=True)

    best = basic
    if len(_digits_only(aggressive)) > len(_digits_only(basic)):
        best = aggressive

    digits = _digits_only(best)
    if not digits:
        return -1.0

    score = 0.0

    score += len(digits) * 2.0

    if "-" in best:
        score += 2.0

    if _has_reasonable_account_shape(best):
        score += 5.0

    if len(digits) >= 11:
        score += 2.0

    if len(digits) >= 13:
        score += 1.0

    score += score_account_pattern(bank_name, best)

    return score


def extract_account_number(
    items_raw: List[Dict[str, Any]],
    full_text: str,
    bank_name: Optional[str] = None,
) -> Optional[str]:
    items = [
        OCRBoxItem(text=i["text"], score=float(i["score"]), box=i["box"])
        for i in items_raw
        if i.get("text")
    ]

    numeric_items = [i for i in items if _numeric_like_score(i.text) >= 0.7]

    raw_candidates: List[str] = []
    raw_candidates.extend(_build_row_candidates(numeric_items))
    # raw_candidates.extend(_build_row_candidates(items))
    # raw_candidates.append(full_text)

    seen = set()
    normalized_candidates: List[str] = []

    for cand in raw_candidates:
        cand_basic = _normalize_account_chars(cand, aggressive=False)
        cand_aggr = _normalize_account_chars(cand, aggressive=True)

        for normalized in [cand_basic, cand_aggr]:
            if not normalized:
                continue

            # 은행 패턴 기반 파생 후보 추가
            variants = _generate_bank_aware_variants(normalized, bank_name)

            ########################################################################
            # print("raw cand =", cand)
            # print("normalized =", normalized)
            # print("variants =", variants)

            for variant in variants:
                if not variant:
                    continue

                digits = _digits_only(variant)

                if len(digits) < 9 or len(digits) > 16:
                    continue

                if variant in seen:
                    continue
                seen.add(variant)
                normalized_candidates.append(variant)

    best_text = None
    best_score = -1.0

    for normalized in normalized_candidates:
        score = _score_account_candidate(normalized, bank_name=bank_name)
        if score > best_score:
            best_score = score
            best_text = normalized

    if not best_text:
        return None

    if not _has_reasonable_account_shape(best_text):
        return None

    return best_text.replace("-", "")

def parse_ocr_fields(items_raw: List[Dict[str, Any]], full_text: str) -> Dict[str, Any]:
    bank_name = extract_bank_name(items_raw, full_text)
    account_number = extract_account_number(items_raw, full_text, bank_name=bank_name)

    pattern_info = get_pattern_match_info(bank_name, account_number)

    return {
        "bank_name": bank_name,
        "account_number": account_number,
        "pattern_info": pattern_info,
    }

def _generate_bank_aware_variants(account_number: str, bank_name: Optional[str]) -> List[str]:
    variants = [account_number]

    if not bank_name or not account_number:
        return variants

    digits = re.sub(r"[^0-9]", "", account_number)

    # 농협/농협은행: 3-4-4-2 형식 강하게 시도
    if bank_name in {"농협", "농협은행"}:
        if len(digits) >= 13:
            v = f"{digits[:3]}-{digits[3:7]}-{digits[7:11]}-{digits[11:13]}"
            variants.append(v)

        # OCR이 마지막에 한 자리 더 붙인 경우 대비
        if len(digits) == 14:
            trimmed = digits[:-1]
            v = f"{trimmed[:3]}-{trimmed[3:7]}-{trimmed[7:11]}-{trimmed[11:13]}"
            variants.append(v)

    return list(dict.fromkeys(variants))