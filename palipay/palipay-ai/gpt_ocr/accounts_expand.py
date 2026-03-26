"""GPT OCR: 엔진·후처리에서 쓰는 은행별 가상 하이픈 후보 확장."""
from __future__ import annotations

from typing import List, Optional

from banking.context import BankPatternContext
from banking.variants import (
    citi_pattern_variants,
    daegu_pattern_variants,
    hana_pattern_variants,
    ibk_pattern_variants,
    jeju_pattern_variants,
    jeonbuk_pattern_variants,
    kakao_pattern_variants,
    kb_pattern_variants,
    kbank_pattern_variants,
    kdb_pattern_variants,
    nonghyup_extended_variants,
    post_office_pattern_variants,
    saemaul_pattern_variants,
    sc_pattern_variants,
    shinhan_pattern_variants,
    suhyup_pattern_variants,
    woori_pattern_variants,
)


def gpt_accounts_to_try(
    ctx: BankPatternContext,
    bank_name: Optional[str],
    account_number: str,
) -> List[str]:
    resolved = ctx.resolve_bank_name(bank_name) if bank_name else None
    if resolved in ("농협은행", "부산은행"):
        return nonghyup_extended_variants(account_number)
    if resolved == "국민은행":
        return kb_pattern_variants(account_number)
    if resolved == "신한은행":
        return shinhan_pattern_variants(account_number)
    if resolved == "우리은행":
        return woori_pattern_variants(account_number)
    if resolved == "하나은행":
        return hana_pattern_variants(account_number)
    if resolved in ("IBK기업은행", "기업은행"):
        return ibk_pattern_variants(account_number)
    if resolved == "카카오뱅크":
        return kakao_pattern_variants(account_number)
    if resolved == "수협은행":
        return suhyup_pattern_variants(account_number)
    if resolved == "우체국":
        return post_office_pattern_variants(account_number)
    if resolved == "새마을금고":
        return saemaul_pattern_variants(account_number)
    if resolved == "전북은행":
        return jeonbuk_pattern_variants(account_number)
    if resolved == "대구은행":
        return daegu_pattern_variants(account_number)
    if resolved == "제주은행":
        return jeju_pattern_variants(account_number)
    if resolved == "씨티은행":
        return citi_pattern_variants(account_number)
    if resolved == "KDB산업은행":
        return kdb_pattern_variants(account_number)
    if resolved == "SC제일은행":
        return sc_pattern_variants(account_number)
    if resolved == "케이뱅크":
        return kbank_pattern_variants(account_number)
    return [account_number]
