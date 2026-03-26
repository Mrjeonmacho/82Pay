"""GPT OCR 파이프라인 공개 API. 규칙 데이터는 gpt_ocr.bank_pattern_data, 공통 엔진은 banking."""
from __future__ import annotations

from typing import Dict, List, Optional

from banking.aliases import BANK_NAME_ALIASES
from banking.context import BankPatternContext
from banking.types import PatternRule

from gpt_ocr.accounts_expand import gpt_accounts_to_try
from gpt_ocr.bank_pattern_data import BANK_ACCOUNT_PATTERNS, LLM_RULE_HINTS

_ctx = BankPatternContext(
    bank_account_patterns=BANK_ACCOUNT_PATTERNS,
    bank_name_aliases=BANK_NAME_ALIASES,
    llm_rule_hints=LLM_RULE_HINTS,
    accounts_to_try_fn=gpt_accounts_to_try,
)


def resolve_bank_name(name: Optional[str]) -> Optional[str]:
    return _ctx.resolve_bank_name(name)


def get_bank_patterns(bank_name: Optional[str]) -> List[PatternRule]:
    return _ctx.get_bank_patterns(bank_name)


def score_account_pattern(bank_name: Optional[str], account_number: Optional[str]) -> float:
    return _ctx.score_account_pattern(bank_name, account_number)


def get_pattern_match_info(bank_name: Optional[str], account_number: Optional[str]) -> Dict[str, object]:
    return _ctx.get_pattern_match_info(bank_name, account_number)


def build_bank_account_rules_for_prompt() -> str:
    return _ctx.build_bank_account_rules_for_prompt()


__all__ = [
    "BANK_ACCOUNT_PATTERNS",
    "BANK_NAME_ALIASES",
    "PatternRule",
    "build_bank_account_rules_for_prompt",
    "get_bank_patterns",
    "get_pattern_match_info",
    "resolve_bank_name",
    "score_account_pattern",
]
