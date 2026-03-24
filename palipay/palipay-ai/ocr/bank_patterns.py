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
    "농협": [
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
    "수협": [
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


def get_bank_patterns(bank_name: Optional[str]) -> List[PatternRule]:
    if not bank_name:
        return []
    return BANK_ACCOUNT_PATTERNS.get(bank_name, [])


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
    if not bank_name or not account_number:
        return {
            "bank_name": bank_name,
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
        "bank_name": bank_name,
        "account_number": account_number,
        "matched": len(matched_rules) > 0,
        "matched_rules": matched_rules,
        "best_score": best_score,
    }