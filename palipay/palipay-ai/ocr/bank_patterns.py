import re
from typing import Dict, List, Pattern, Optional


PatternRule = Dict[str, object]


BANK_ACCOUNT_PATTERNS: Dict[str, List[PatternRule]] = {
    "국민은행": [
        {
            "name": "digits_only_10_14",
            "regex": re.compile(r"^\d{10,14}$"),
            "score": 2.0,
        },
        {
            "name": "hyphen_3part_general",
            "regex": re.compile(r"^\d{2,6}-\d{2,6}-\d{2,8}$"),
            "score": 3.0,
        },
    ],
    "신한은행": [
        {
            "name": "digits_only_11",
            "regex": re.compile(r"^\d{11}$"),
            "score": 3.0,
        },
        {
            "name": "digits_only_12",
            "regex": re.compile(r"^\d{12}$"),
            "score": 4.0,
        },
        {
            "name": "hyphen_3part_general",
            "regex": re.compile(r"^\d{2,6}-\d{2,6}-\d{2,8}$"),
            "score": 3.0,
        },
    ],
    "우리은행": [
        {
            "name": "digits_only_13",
            "regex": re.compile(r"^\d{13}$"),
            "score": 3.0,
        },
        {
            "name": "hyphen_4_3_6",
            "regex": re.compile(r"^\d{4}-\d{3}-\d{6}$"),
            "score": 5.0,
        },
        {
            "name": "hyphen_general",
            "regex": re.compile(r"^\d{2,6}-\d{2,6}-\d{2,8}$"),
            "score": 2.0,
        },
    ],
    "하나은행": [
        {
            "name": "digits_only_14",
            "regex": re.compile(r"^\d{14}$"),
            "score": 3.0,
        },
        {
            "name": "hyphen_3_6_5",
            "regex": re.compile(r"^\d{3}-\d{6}-\d{5}$"),
            "score": 5.0,
        },
        {
            "name": "hyphen_general",
            "regex": re.compile(r"^\d{2,6}-\d{2,6}-\d{2,8}$"),
            "score": 2.0,
        },
    ],
    "농협은행": [
        {
            "name": "digits_only_13",
            "regex": re.compile(r"^\d{13}$"),
            "score": 3.0,
        },
        {
            "name": "hyphen_3_4_6",
            "regex": re.compile(r"^\d{3}-\d{4}-\d{6}$"),
            "score": 5.0,
        },
        {
            "name": "hyphen_3_4_4_2",
            "regex": re.compile(r"^\d{3}-\d{4}-\d{4}-\d{2}$"),
            "score": 6.0,
        },
        {
            "name": "hyphen_4part_general",
            "regex": re.compile(r"^\d{2,6}(-\d{1,6}){3}$"),
            "score": 3.0,
        },
        {
            "name": "hyphen_general",
            "regex": re.compile(r"^\d{2,6}-\d{2,6}-\d{2,8}$"),
            "score": 2.0,
        },
    ],
    "기업은행": [
        {
            "name": "digits_only_11_14",
            "regex": re.compile(r"^\d{11,14}$"),
            "score": 2.0,
        },
        {
            "name": "hyphen_general",
            "regex": re.compile(r"^\d{2,6}-\d{2,6}-\d{2,8}$"),
            "score": 3.0,
        },
    ],
    "IBK기업은행": [
        {
            "name": "digits_only_11_14",
            "regex": re.compile(r"^\d{11,14}$"),
            "score": 2.0,
        },
        {
            "name": "hyphen_general",
            "regex": re.compile(r"^\d{2,6}-\d{2,6}-\d{2,8}$"),
            "score": 3.0,
        },
    ],
    "새마을금고": [
        {
            "name": "digits_only_13_14",
            "regex": re.compile(r"^\d{13,14}$"),
            "score": 3.0,
        },
        {
            "name": "hyphen_4part",
            "regex": re.compile(r"^\d{4}-\d{4}-\d{4}-\d{1,2}$"),
            "score": 6.0,
        },
        {
            "name": "hyphen_general_3or4part",
            "regex": re.compile(r"^\d{2,6}(-\d{1,6}){2,3}$"),
            "score": 3.0,
        },
    ],
    "수협은행": [
        {
            "name": "digits_only_11_14",
            "regex": re.compile(r"^\d{11,14}$"),
            "score": 2.0,
        },
        {
            "name": "hyphen_general",
            "regex": re.compile(r"^\d{2,6}-\d{2,6}-\d{2,8}$"),
            "score": 3.0,
        },
    ],
    "SC제일은행": [
        {
            "name": "digits_only_11_14",
            "regex": re.compile(r"^\d{11,14}$"),
            "score": 2.0,
        },
        {
            "name": "hyphen_general",
            "regex": re.compile(r"^\d{2,6}-\d{2,6}-\d{2,8}$"),
            "score": 3.0,
        },
    ],
    "부산은행": [
        {
            "name": "digits_only_10_14",
            "regex": re.compile(r"^\d{10,14}$"),
            "score": 2.0,
        },
        {
            "name": "hyphen_general",
            "regex": re.compile(r"^\d{2,6}-\d{2,6}-\d{2,8}$"),
            "score": 3.0,
        },
    ],
    "대구은행": [
        {
            "name": "digits_only_10_14",
            "regex": re.compile(r"^\d{10,14}$"),
            "score": 2.0,
        },
        {
            "name": "hyphen_general",
            "regex": re.compile(r"^\d{2,6}-\d{2,6}-\d{2,8}$"),
            "score": 3.0,
        },
    ],
    "광주은행": [
        {
            "name": "digits_only_10_14",
            "regex": re.compile(r"^\d{10,14}$"),
            "score": 2.0,
        },
        {
            "name": "hyphen_general",
            "regex": re.compile(r"^\d{2,6}-\d{2,6}-\d{2,8}$"),
            "score": 3.0,
        },
    ],
    "전북은행": [
        {
            "name": "digits_only_10_14",
            "regex": re.compile(r"^\d{10,14}$"),
            "score": 2.0,
        },
        {
            "name": "hyphen_general",
            "regex": re.compile(r"^\d{2,6}-\d{2,6}-\d{2,8}$"),
            "score": 3.0,
        },
    ],
    "경남은행": [
        {
            "name": "digits_only_10_14",
            "regex": re.compile(r"^\d{10,14}$"),
            "score": 2.0,
        },
        {
            "name": "hyphen_general",
            "regex": re.compile(r"^\d{2,6}-\d{2,6}-\d{2,8}$"),
            "score": 3.0,
        },
    ],
    "카카오뱅크": [
        {
            "name": "digits_only_13",
            "regex": re.compile(r"^\d{13}$"),
            "score": 3.0,
        },
        {
            "name": "hyphen_general",
            "regex": re.compile(r"^\d{2,6}-\d{2,6}-\d{2,8}$"),
            "score": 2.0,
        },
    ],
    "케이뱅크": [
        {
            "name": "digits_only_12_14",
            "regex": re.compile(r"^\d{12,14}$"),
            "score": 3.0,
        },
        {
            "name": "hyphen_general",
            "regex": re.compile(r"^\d{2,6}-\d{2,6}-\d{2,8}$"),
            "score": 2.0,
        },
    ],
    "토스뱅크": [
        {
            "name": "digits_only_12_14",
            "regex": re.compile(r"^\d{12,14}$"),
            "score": 3.0,
        },
        {
            "name": "hyphen_general",
            "regex": re.compile(r"^\d{2,6}-\d{2,6}-\d{2,8}$"),
            "score": 2.0,
        },
    ],
    "우체국": [
        {
            "name": "digits_only_10_14",
            "regex": re.compile(r"^\d{10,14}$"),
            "score": 2.0,
        },
        {
            "name": "hyphen_general",
            "regex": re.compile(r"^\d{2,6}-\d{2,6}-\d{2,8}$"),
            "score": 3.0,
        },
    ],
}


# OCR·입력 별칭 → BANK_ACCOUNT_PATTERNS 키(표준명). 키는 공백 제거 후 소문자로 조회(_ALIASES_CF).
BANK_NAME_ALIASES: Dict[str, str] = {
    "국민": "국민은행",
    "kb": "국민은행",
    "kb국민": "국민은행",
    "kb국민은행": "국민은행",
    "신한": "신한은행",
    "shinhan": "신한은행",
    "shinhan은행": "신한은행",
    "shinhanbank": "신한은행",
    "우리": "우리은행",
    "woori": "우리은행",
    "wooribank": "우리은행",
    "하나": "하나은행",
    "hana": "하나은행",
    "hanabank": "하나은행",
    "농협": "농협은행",
    "수협": "수협은행",
    "nh": "농협은행",
    "nh농협": "농협은행",
    "nh농협은행": "농협은행",
    "ibk": "IBK기업은행",
    "새마을": "새마을금고",
    "mg": "새마을금고",
    "sc": "SC제일은행",
    "sc제일": "SC제일은행",
    "카카오": "카카오뱅크",
    "kakao": "카카오뱅크",
    "kakaobank": "카카오뱅크",
    "kbank": "케이뱅크",
    "k뱅크": "케이뱅크",
    "토스": "토스뱅크",
    "toss": "토스뱅크",
    "tossbank": "토스뱅크",
    "우편": "우체국",
}


_ALIASES_CF: Dict[str, str] = {k.casefold(): v for k, v in BANK_NAME_ALIASES.items()}


def _normalize_bank_alias_key(s: str) -> str:
    s = s.replace(" ", "").replace("\n", "").replace("\t", "")
    return s


def resolve_bank_name(name: Optional[str]) -> Optional[str]:
    """별칭·대소문자 변형을 표준명(BANK_ACCOUNT_PATTERNS 키)으로 통일한다."""
    if not name:
        return None
    key = _normalize_bank_alias_key(name.strip())
    if not key:
        return None
    if key in BANK_ACCOUNT_PATTERNS:
        return key
    kcf = key.casefold()
    if kcf in _ALIASES_CF:
        return _ALIASES_CF[kcf]
    for canon in BANK_ACCOUNT_PATTERNS:
        if canon.casefold() == kcf:
            return canon
    return name


def get_bank_patterns(bank_name: Optional[str]) -> List[PatternRule]:
    if not bank_name:
        return []
    resolved = resolve_bank_name(bank_name)
    if not resolved or resolved not in BANK_ACCOUNT_PATTERNS:
        return []
    return BANK_ACCOUNT_PATTERNS[resolved]


def score_account_pattern(bank_name: Optional[str], account_number: Optional[str]) -> float:
    if not bank_name or not account_number:
        return 0.0

    patterns = get_bank_patterns(bank_name)
    if not patterns:
        return 0.0

    best_score = 0.0
    for pattern in patterns:
        regex: Pattern[str] = pattern["regex"]  # type: ignore[assignment]
        if regex.match(account_number):
            score = float(pattern["score"])  # type: ignore[arg-type]
            if score > best_score:
                best_score = score

    return best_score


def get_pattern_match_info(bank_name: Optional[str], account_number: Optional[str]) -> Dict[str, object]:
    resolved = resolve_bank_name(bank_name) if bank_name else bank_name
    if not bank_name or not account_number:
        return {
            "bank_name": resolved,
            "account_number": account_number,
            "matched": False,
            "matched_rules": [],
            "best_score": 0.0,
        }

    patterns = get_bank_patterns(bank_name)

    matched_rules: List[str] = []
    best_score = 0.0

    for pattern in patterns:
        regex: Pattern[str] = pattern["regex"]  # type: ignore[assignment]
        if regex.match(account_number):
            rule_name = str(pattern["name"])
            rule_score = float(pattern["score"])  # type: ignore[arg-type]
            matched_rules.append(rule_name)
            if rule_score > best_score:
                best_score = rule_score

    return {
        "bank_name": resolved,
        "account_number": account_number,
        "matched": len(matched_rules) > 0,
        "matched_rules": matched_rules,
        "best_score": best_score,
    }