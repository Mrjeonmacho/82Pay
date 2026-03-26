from __future__ import annotations

from dataclasses import dataclass
from difflib import SequenceMatcher
from typing import Any, Dict, List, Optional, Tuple
import re

from banking.variants import hyphen_variant_strings

from .bank_patterns import (
    BANK_NAME_ALIASES,
    get_pattern_match_info,
    resolve_bank_name,
    score_account_pattern,
)


BANK_CANDIDATES = [
    "국민은행",
    "신한은행",
    "우리은행",
    "하나은행",
    "농협은행",
    "기업은행",
    "IBK기업은행",
    "새마을금고",
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
    "제주은행",
    "씨티은행",
    "KDB산업은행",
]


def _build_bank_substring_needles() -> List[Tuple[str, str]]:
    pairs: List[Tuple[str, str]] = []
    for bank in BANK_CANDIDATES:
        pairs.append((bank, bank))
    for alias, canonical in BANK_NAME_ALIASES.items():
        pairs.append((alias, canonical))
    pairs.sort(key=lambda x: len(x[0]), reverse=True)
    return pairs


_BANK_SUBSTRING_NEEDLES = _build_bank_substring_needles()


def _build_fuzzy_bank_strings() -> List[str]:
    seen: set[str] = set()
    out: List[str] = []
    for s in BANK_CANDIDATES:
        cf = s.casefold()
        if cf not in seen:
            seen.add(cf)
            out.append(s)
    for alias in BANK_NAME_ALIASES:
        cf = alias.casefold()
        if cf not in seen:
            seen.add(cf)
            out.append(alias)
    return out


_FUZZY_BANK_STRINGS = _build_fuzzy_bank_strings()

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
    if not text:
        return None
    tcf = text.casefold()
    for needle, canonical in _BANK_SUBSTRING_NEEDLES:
        if needle.casefold() in tcf:
            return canonical
    return None


def _best_bank_by_fuzzy(text: str) -> Tuple[Optional[str], float]:
    best_bank = None
    best_score = 0.0

    for bank in _FUZZY_BANK_STRINGS:
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

    resolved = resolve_bank_name(best_bank) if best_bank else None
    return resolved, best_score


def extract_bank_name(items_raw: List[Dict[str, Any]], full_text: str) -> Optional[str]:
    full = _clean_for_bank(full_text)

    direct = _best_bank_by_substring(full)
    if direct:
        return resolve_bank_name(direct)

    item_texts = [_clean_for_bank(i["text"]) for i in items_raw if i.get("text")]
    for t in item_texts:
        direct = _best_bank_by_substring(t)
        if direct:
            return resolve_bank_name(direct)

    text_for_match = full
    for noise in NOISE_WORDS:
        text_for_match = text_for_match.replace(noise, "")

    fuzzy_bank, fuzzy_score = _best_bank_by_fuzzy(text_for_match)
    if fuzzy_bank and fuzzy_score >= 0.72:
        return resolve_bank_name(fuzzy_bank)

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
        return resolve_bank_name(best_bank)

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


# full_text 원문에 남아 있는 대표 하이픈 형식 (GPT가 account_number 를 잘리게 줄 때 보정)
_FULLTEXT_HYPHEN_PATTERNS_BY_BANK: Dict[str, List[str]] = {
    "국민은행": [
        r"\d{3}\s*-\s*\d{2}\s*-\s*\d{4}\s*-\s*\d{3}",
        r"\d{6}\s*-\s*\d{2}\s*-\s*\d{6}",
    ],
    "신한은행": [
        r"\d{3}\s*-\s*\d{2}\s*-\s*\d{6}",
        r"\d{3}\s*-\s*\d{3}\s*-\s*\d{6}",
    ],
    "우리은행": [r"\d{4}\s*-\s*\d{3}\s*-\s*\d{6}"],
    "하나은행": [r"\d{3}\s*-\s*\d{6}\s*-\s*\d{5}"],
    "농협은행": [
        r"\d{3}\s*-\s*\d{4}\s*-\s*\d{4}\s*-\s*\d{2}",
        r"\d{3}\s*-\s*\d{4}\s*-\s*\d{6}",
    ],
    "IBK기업은행": [r"\d{3}\s*-\s*\d{6}\s*-\s*\d{2}\s*-\s*\d{3}"],
    "기업은행": [r"\d{3}\s*-\s*\d{6}\s*-\s*\d{2}\s*-\s*\d{3}"],
    "수협은행": [r"\d{3}\s*-\s*\d{2}\s*-\s*\d{6}"],
    "새마을금고": [
        r"\d{4}\s*-\s*\d{4}\s*-\s*\d{4}\s*-\s*\d{1}",
        r"\d{3}\s*-\s*\d{2}\s*-\s*\d{6}\s*-\s*\d{1}",
    ],
    "우체국": [r"\d{6}\s*-\s*\d{2}\s*-\s*\d{6}"],
    "카카오뱅크": [r"\d{4}\s*-\s*\d{2}\s*-\s*\d{7}"],
    "케이뱅크": [r"\d{3}\s*-\s*\d{3}\s*-\s*\d{7}"],
    "SC제일은행": [r"\d{3}\s*-\s*\d{2}\s*-\s*\d{6}"],
    "부산은행": [r"\d{3}\s*-\s*\d{4}\s*-\s*\d{4}\s*-\s*\d{2}"],
    "대구은행": [r"\d{3}\s*-\s*\d{2}\s*-\s*\d{6}\s*-\s*\d{1}"],
    "전북은행": [r"\d{3}\s*-\s*\d{6}\s*-\s*\d{3}"],
    "제주은행": [r"\d{2}\s*-\s*\d{2}\s*-\s*\d{6}"],
    "씨티은행": [r"\d{3}\s*-\s*\d{6}\s*-\s*\d{3}"],
    "KDB산업은행": [r"\d{3}\s*-\s*\d{4}\s*-\s*\d{4}\s*-\s*\d{3}"],
}


def extract_account_from_full_text_hyphen_patterns(
    full_text: str,
    bank_name: Optional[str],
) -> Optional[str]:
    """
    full_text 문자열에서 해당 은행 대표 하이픈 패턴을 찾아 숫자만 반환.
    한 줄에 '우리은행 1002-851-616246'처럼 붙어 있어도 매칭된다.
    """
    if not bank_name or not (full_text or "").strip():
        return None
    resolved = resolve_bank_name(bank_name)
    if not resolved or resolved not in _FULLTEXT_HYPHEN_PATTERNS_BY_BANK:
        return None
    text = full_text.strip()
    candidates: List[str] = []
    for pat in _FULLTEXT_HYPHEN_PATTERNS_BY_BANK[resolved]:
        for m in re.finditer(pat, text):
            digits = re.sub(r"[^0-9]", "", m.group(0))
            if 9 <= len(digits) <= 16:
                candidates.append(digits)
    if not candidates:
        return None
    best: Optional[str] = None
    best_rank: Tuple[float, int] = (-1.0, -1)
    for d in dict.fromkeys(candidates):
        pi = get_pattern_match_info(bank_name, d)
        rank = (float(pi.get("best_score", 0)), len(d))
        if rank > best_rank:
            best_rank = rank
            best = d
    return best


def parse_ocr_fields(items_raw: List[Dict[str, Any]], full_text: str) -> Dict[str, Any]:
    bank_name = resolve_bank_name(extract_bank_name(items_raw, full_text))
    account_number = extract_account_number(items_raw, full_text, bank_name=bank_name)

    pattern_info = get_pattern_match_info(bank_name, account_number)

    return {
        "bank_name": bank_name,
        "account_number": account_number,
        "pattern_info": pattern_info,
    }

def _generate_bank_aware_variants(account_number: str, bank_name: Optional[str]) -> List[str]:
    resolved = resolve_bank_name(bank_name) if bank_name else None
    return hyphen_variant_strings(account_number, resolved)


def merge_gpt_account_with_postprocess(
    bank_name: Optional[str],
    account_gpt: Optional[str],
    items: List[Dict[str, Any]],
    full_text: str,
) -> tuple[Optional[str], str]:
    """
    GPT가 짧은 계좌만 줄 때 Paddle과 동일한 extract_account_number 로
    full_text 에서 후보를 다시 뽑아 bank_patterns 에 더 잘 맞는 쪽을 선택한다.
    """
    ft = (full_text or "").strip()
    if not bank_name or not ft or not items:
        return account_gpt, "gpt_only"

    refined = extract_account_number(items, ft, bank_name=bank_name)
    pi_g = get_pattern_match_info(bank_name, account_gpt)
    pi_r = get_pattern_match_info(bank_name, refined) if refined else None
    matched_g = bool(pi_g.get("matched"))
    matched_r = bool(pi_r.get("matched")) if pi_r else False

    if refined and matched_r and not matched_g:
        return refined, "postprocess_pattern_fix"
    if refined and not account_gpt:
        return refined, "postprocess_fill"
    if refined and matched_r and matched_g:
        sg = float(pi_g.get("best_score", 0))
        sr = float(pi_r.get("best_score", 0))
        if sr > sg:
            return refined, "postprocess_higher_score"
    return account_gpt, "gpt"


def apply_fulltext_hyphen_account(
    bank_name: Optional[str],
    full_text: str,
    account_number: Optional[str],
    account_source: str,
) -> tuple[Optional[str], str]:
    """full_text 안 하이픈 덩어리가 더 완전하면 GPT/후처리 결과를 덮어쓴다."""
    ft = extract_account_from_full_text_hyphen_patterns(full_text, bank_name)
    if not ft or not bank_name:
        return account_number, account_source
    pi_ft = get_pattern_match_info(bank_name, ft)
    if not pi_ft.get("matched"):
        return account_number, account_source
    pi_cur = get_pattern_match_info(bank_name, account_number)
    cur_m = bool(pi_cur.get("matched")) if account_number else False
    ft_score = float(pi_ft.get("best_score", 0))
    cur_score = float(pi_cur.get("best_score", 0)) if account_number else -1.0
    ln_ft, ln_cur = len(ft), len(account_number or "")
    if not cur_m or ln_ft > ln_cur or ft_score > cur_score + 1e-6:
        return ft, f"{account_source}+fulltext_hyphen"
    return account_number, account_source