"""GPT OCR용 계좌 정규식 사전·프롬프트 힌트. 런타임은 gpt_ocr.bank_patterns."""
from __future__ import annotations

import re
from typing import Dict, List

from banking.types import PatternRule


BANK_ACCOUNT_PATTERNS: Dict[str, List[PatternRule]] = {
    "국민은행": [
        {
            "name": "hyphen_3_2_4_3",
            "regex": re.compile(r"^\d{3}-\d{2}-\d{4}-\d{3}$"),
            "score": 6.0,
        },
        {
            "name": "hyphen_6_2_6_old",
            "regex": re.compile(r"^\d{6}-\d{2}-\d{6}$"),
            "score": 5.5,
        },
        {
            "name": "digits_only_12",
            "regex": re.compile(r"^\d{12}$"),
            "score": 4.0,
        },
        {
            "name": "digits_only_14",
            "regex": re.compile(r"^\d{14}$"),
            "score": 3.5,
        },
    ],
    "신한은행": [
        {
            "name": "hyphen_3_2_6",
            "regex": re.compile(r"^\d{3}-\d{2}-\d{6}$"),
            "score": 6.0,
        },
        {
            "name": "hyphen_3_3_6_old",
            "regex": re.compile(r"^\d{3}-\d{3}-\d{6}$"),
            "score": 5.5,
        },
        {
            "name": "digits_only_11",
            "regex": re.compile(r"^\d{11}$"),
            "score": 4.0,
        },
        {
            "name": "digits_only_12_optional",
            "regex": re.compile(r"^\d{12}$"),
            "score": 2.5,
        },
    ],
    "우리은행": [
        {
            "name": "hyphen_4_3_6",
            "regex": re.compile(r"^\d{4}-\d{3}-\d{6}$"),
            "score": 6.0,
        },
        {
            "name": "digits_only_13",
            "regex": re.compile(r"^\d{13}$"),
            "score": 4.0,
        },
    ],
    "하나은행": [
        {
            "name": "hyphen_3_6_5",
            "regex": re.compile(r"^\d{3}-\d{6}-\d{5}$"),
            "score": 6.0,
        },
        {
            "name": "digits_only_14",
            "regex": re.compile(r"^\d{14}$"),
            "score": 4.0,
        },
    ],
    "농협은행": [
        {
            "name": "hyphen_3_4_4_2",
            "regex": re.compile(r"^\d{3}-\d{4}-\d{4}-\d{2}$"),
            "score": 6.0,
        },
        {
            "name": "hyphen_3_4_6",
            "regex": re.compile(r"^\d{3}-\d{4}-\d{6}$"),
            "score": 5.0,
        },
        {
            "name": "digits_only_13",
            "regex": re.compile(r"^\d{13}$"),
            "score": 3.0,
        },
    ],
    "IBK기업은행": [
        {
            "name": "hyphen_3_6_2_3",
            "regex": re.compile(r"^\d{3}-\d{6}-\d{2}-\d{3}$"),
            "score": 6.0,
        },
        {
            "name": "digits_only_14",
            "regex": re.compile(r"^\d{14}$"),
            "score": 4.0,
        },
        {
            "name": "digits_only_10_11_lifetime_optional",
            "regex": re.compile(r"^\d{10,11}$"),
            "score": 1.5,
        },
    ],
    "기업은행": [
        {
            "name": "hyphen_3_6_2_3",
            "regex": re.compile(r"^\d{3}-\d{6}-\d{2}-\d{3}$"),
            "score": 6.0,
        },
        {
            "name": "digits_only_14",
            "regex": re.compile(r"^\d{14}$"),
            "score": 4.0,
        },
        {
            "name": "digits_only_10_11_lifetime_optional",
            "regex": re.compile(r"^\d{10,11}$"),
            "score": 1.5,
        },
    ],
    "새마을금고": [
        {
            "name": "hyphen_4_4_4_1",
            "regex": re.compile(r"^\d{4}-\d{4}-\d{4}-\d{1}$"),
            "score": 6.0,
        },
        {
            "name": "hyphen_3_2_6_1",
            "regex": re.compile(r"^\d{3}-\d{2}-\d{6}-\d{1}$"),
            "score": 5.5,
        },
        {
            "name": "digits_only_13",
            "regex": re.compile(r"^\d{13}$"),
            "score": 3.5,
        },
        {
            "name": "digits_only_12",
            "regex": re.compile(r"^\d{12}$"),
            "score": 3.5,
        },
    ],
    "수협은행": [
        {
            "name": "hyphen_3_2_6",
            "regex": re.compile(r"^\d{3}-\d{2}-\d{6}$"),
            "score": 6.0,
        },
        {
            "name": "digits_only_11",
            "regex": re.compile(r"^\d{11}$"),
            "score": 4.0,
        },
    ],
    "SC제일은행": [
        {
            "name": "hyphen_3_2_6",
            "regex": re.compile(r"^\d{3}-\d{2}-\d{6}$"),
            "score": 6.0,
        },
        {
            "name": "digits_only_11",
            "regex": re.compile(r"^\d{11}$"),
            "score": 4.0,
        },
    ],
    "부산은행": [
        {
            "name": "hyphen_3_4_4_2",
            "regex": re.compile(r"^\d{3}-\d{4}-\d{4}-\d{2}$"),
            "score": 6.0,
        },
        {
            "name": "digits_only_13",
            "regex": re.compile(r"^\d{13}$"),
            "score": 4.0,
        },
    ],
    "대구은행": [
        {
            "name": "hyphen_3_2_6_1",
            "regex": re.compile(r"^\d{3}-\d{2}-\d{6}-\d{1}$"),
            "score": 6.0,
        },
        {
            "name": "digits_only_12",
            "regex": re.compile(r"^\d{12}$"),
            "score": 4.0,
        },
    ],
    "광주은행": [
        {
            "name": "digits_only_10_14",
            "regex": re.compile(r"^\d{10,14}$"),
            "score": 2.5,
        },
    ],
    "전북은행": [
        {
            "name": "hyphen_3_6_3",
            "regex": re.compile(r"^\d{3}-\d{6}-\d{3}$"),
            "score": 6.0,
        },
        {
            "name": "digits_only_12",
            "regex": re.compile(r"^\d{12}$"),
            "score": 4.0,
        },
    ],
    "경남은행": [
        {
            "name": "digits_only_10_14",
            "regex": re.compile(r"^\d{10,14}$"),
            "score": 2.5,
        },
    ],
    "카카오뱅크": [
        {
            "name": "hyphen_4_2_7",
            "regex": re.compile(r"^\d{4}-\d{2}-\d{7}$"),
            "score": 6.0,
        },
        {
            "name": "digits_only_13",
            "regex": re.compile(r"^\d{13}$"),
            "score": 4.0,
        },
        {
            "name": "prefix_333",
            "regex": re.compile(r"^333\d{8}$"),
            "score": 3.0,
        },
    ],
    "케이뱅크": [
        {
            "name": "hyphen_3_3_7",
            "regex": re.compile(r"^\d{3}-\d{3}-\d{7}$"),
            "score": 6.0,
        },
        {
            "name": "digits_only_13",
            "regex": re.compile(r"^\d{13}$"),
            "score": 4.0,
        },
        {
            "name": "prefix_100_optional",
            "regex": re.compile(r"^100\d{10}$"),
            "score": 3.5,
        },
    ],
    "토스뱅크": [
        {
            "name": "digits_only_12_14",
            "regex": re.compile(r"^\d{12,14}$"),
            "score": 3.0,
        },
        {
            "name": "hyphen_3_3_6_or_7",
            "regex": re.compile(r"^\d{3}-\d{3,4}-\d{5,7}$"),
            "score": 2.0,
        },
    ],
    "우체국": [
        {
            "name": "hyphen_6_2_6",
            "regex": re.compile(r"^\d{6}-\d{2}-\d{6}$"),
            "score": 6.0,
        },
        {
            "name": "digits_only_14",
            "regex": re.compile(r"^\d{14}$"),
            "score": 4.0,
        },
    ],
    "제주은행": [
        {
            "name": "hyphen_2_2_6",
            "regex": re.compile(r"^\d{2}-\d{2}-\d{6}$"),
            "score": 6.0,
        },
        {
            "name": "digits_only_10",
            "regex": re.compile(r"^\d{10}$"),
            "score": 4.0,
        },
    ],
    "씨티은행": [
        {
            "name": "hyphen_3_6_3",
            "regex": re.compile(r"^\d{3}-\d{6}-\d{3}$"),
            "score": 6.0,
        },
        {
            "name": "digits_only_12",
            "regex": re.compile(r"^\d{12}$"),
            "score": 4.0,
        },
    ],
    "KDB산업은행": [
        {
            "name": "hyphen_3_4_4_3",
            "regex": re.compile(r"^\d{3}-\d{4}-\d{4}-\d{3}$"),
            "score": 6.0,
        },
        {
            "name": "digits_only_14",
            "regex": re.compile(r"^\d{14}$"),
            "score": 4.0,
        },
    ],
}


# 프롬프트용: rule name → 자연어 (BANK_ACCOUNT_PATTERNS 와 1:1 대응)
LLM_RULE_HINTS: Dict[str, str] = {
    "hyphen_3_2_4_3": "하이픈 3-2-4-3 (국민 신형 12자리)",
    "hyphen_6_2_6_old": "하이픈 6-2-6 (국민 구형 14자리)",
    "digits_only_12": "연속 숫자 12자리",
    "digits_only_14": "연속 숫자 14자리",
    "hyphen_3_2_6": "하이픈 3-2-6 (신한 11자리·수협·SC 등)",
    "hyphen_3_3_6_old": "하이픈 3-3-6 (신한 구형 12자리)",
    "digits_only_11": "연속 숫자 11자리",
    "digits_only_12_optional": "연속 숫자 12자리(보조)",
    "hyphen_4_3_6": "하이픈 4-3-6 (우리 13자리)",
    "digits_only_13": "연속 숫자 13자리",
    "hyphen_3_6_5": "하이픈 3-6-5 (하나 14자리)",
    "hyphen_3_6_2_3": "하이픈 3-6-2-3 (IBK·기업 14자리)",
    "digits_only_10_11_lifetime_optional": "연속 10~11자리(평생 등 예외)",
    "hyphen_3_4_6": "하이픈 3-4-6 (NH 변형 13자리)",
    "hyphen_3_4_4_2": "하이픈 3-4-4-2 (NH·부산 13자리)",
    "hyphen_4_2_7": "하이픈 4-2-7 (카카오 13자리)",
    "hyphen_4_4_4_1": "하이픈 4-4-4-1 (새마을 13자리)",
    "hyphen_3_2_6_1": "하이픈 3-2-6-1 (새마을·대구 12자리)",
    "hyphen_6_2_6": "하이픈 6-2-6 (우체국 14자리)",
    "hyphen_3_3_7": "하이픈 3-3-7 (케이뱅크 13자리)",
    "prefix_333": "333으로 시작 (구 카카오 등, 보조)",
    "prefix_100_optional": "100으로 시작 (케이뱅크 등)",
    "digits_only_12_14": "연속 숫자 12~14자리",
    "hyphen_3_3_6_or_7": "하이픈 3-(3~4)-(5~7) (토스 등)",
    "digits_only_10_14": "연속 숫자 10~14자리",
    "digits_only_11_14": "연속 숫자 11~14자리",
    "digits_only_13_14": "연속 숫자 13~14자리",
    "hyphen_3_6_3": "하이픈 3-6-3 (전북·씨티 12자리)",
    "hyphen_2_2_6": "하이픈 2-2-6 (제주 10자리)",
    "hyphen_3_4_4_3": "하이픈 3-4-4-3 (KDB산업 14자리)",
    "digits_only_10": "연속 숫자 10자리",
    "hyphen_4part": "하이픈 4-4-4-(1~2) (레거시)",
    "hyphen_general_3or4part": "하이픈 3~4덩어리 일반형",
}