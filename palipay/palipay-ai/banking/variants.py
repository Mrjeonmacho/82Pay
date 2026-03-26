"""패턴 매칭·후처리용 계좌 문자열 변형(은행 공시 형식 기준 가상 하이픈)."""
from __future__ import annotations

import re
from typing import List, Optional


def digits_only(s: str) -> str:
    return re.sub(r"[^0-9]", "", s)


def uniq_strs(xs: List[str]) -> List[str]:
    return list(dict.fromkeys(x for x in xs if x))


def nonghyup_pattern_match_variants(account_number: str) -> List[str]:
    acc = account_number.strip()
    out: List[str] = [acc]
    d = digits_only(acc)
    if len(d) == 13:
        hy = f"{d[:3]}-{d[3:7]}-{d[7:11]}-{d[11:13]}"
        out.append(hy)
    return uniq_strs(out)


def nonghyup_extended_variants(account_number: str) -> List[str]:
    """농협·부산(13자리 3-4-4-2) 등 + 14자리 OCR 오인식 시 1자리 제거 후 시도."""
    acc = account_number.strip()
    out: List[str] = [acc]
    d = digits_only(acc)
    if len(d) >= 13:
        v = f"{d[:3]}-{d[3:7]}-{d[7:11]}-{d[11:13]}"
        out.append(v)
    if len(d) == 14:
        trimmed = d[:-1]
        v = f"{trimmed[:3]}-{trimmed[3:7]}-{trimmed[7:11]}-{trimmed[11:13]}"
        out.append(v)
    return uniq_strs(out)


def kb_pattern_variants(account_number: str) -> List[str]:
    """국민: 신형 12자리 3-2-4-3, 구형 14자리 6-2-6."""
    acc = account_number.strip()
    out = [acc]
    d = digits_only(acc)
    if len(d) == 12:
        out.append(f"{d[:3]}-{d[3:5]}-{d[5:9]}-{d[9:12]}")
    if len(d) == 14:
        out.append(f"{d[:6]}-{d[6:8]}-{d[8:14]}")
    return uniq_strs(out)


def shinhan_pattern_variants(account_number: str) -> List[str]:
    """신한: 11자리 3-2-6, 구형 12자리 3-3-6."""
    acc = account_number.strip()
    out = [acc]
    d = digits_only(acc)
    if len(d) == 11:
        out.append(f"{d[:3]}-{d[3:5]}-{d[5:11]}")
    if len(d) == 12:
        out.append(f"{d[:3]}-{d[3:6]}-{d[6:12]}")
    return uniq_strs(out)


def woori_pattern_variants(account_number: str) -> List[str]:
    acc = account_number.strip()
    out = [acc]
    d = digits_only(acc)
    if len(d) == 13:
        out.append(f"{d[:4]}-{d[4:7]}-{d[7:13]}")
    return uniq_strs(out)


def hana_pattern_variants(account_number: str) -> List[str]:
    """하나: 14자리 3-6-5."""
    acc = account_number.strip()
    out = [acc]
    d = digits_only(acc)
    if len(d) == 14:
        out.append(f"{d[:3]}-{d[3:9]}-{d[9:14]}")
    return uniq_strs(out)


def kbank_pattern_variants(account_number: str) -> List[str]:
    """케이뱅크: 13자리 3-3-7(기존 규칙 유지)."""
    acc = account_number.strip()
    out = [acc]
    d = digits_only(acc)
    if len(d) == 13:
        out.append(f"{d[:3]}-{d[3:6]}-{d[6:13]}")
    return uniq_strs(out)


def ibk_pattern_variants(account_number: str) -> List[str]:
    """IBK·기업: 14자리 3-6-2-3."""
    acc = account_number.strip()
    out = [acc]
    d = digits_only(acc)
    if len(d) == 14:
        out.append(f"{d[:3]}-{d[3:9]}-{d[9:11]}-{d[11:14]}")
    return uniq_strs(out)


def kakao_pattern_variants(account_number: str) -> List[str]:
    """카카오뱅크: 13자리 4-2-7."""
    acc = account_number.strip()
    out = [acc]
    d = digits_only(acc)
    if len(d) == 13:
        out.append(f"{d[:4]}-{d[4:6]}-{d[6:13]}")
    return uniq_strs(out)


def suhyup_pattern_variants(account_number: str) -> List[str]:
    """수협: 11자리 3-2-6."""
    acc = account_number.strip()
    out = [acc]
    d = digits_only(acc)
    if len(d) == 11:
        out.append(f"{d[:3]}-{d[3:5]}-{d[5:11]}")
    return uniq_strs(out)


def post_office_pattern_variants(account_number: str) -> List[str]:
    """우체국: 14자리 6-2-6."""
    acc = account_number.strip()
    out = [acc]
    d = digits_only(acc)
    if len(d) == 14:
        out.append(f"{d[:6]}-{d[6:8]}-{d[8:14]}")
    return uniq_strs(out)


def saemaul_pattern_variants(account_number: str) -> List[str]:
    """새마을: 13자리 4-4-4-1, 12자리 3-2-6-1."""
    acc = account_number.strip()
    out = [acc]
    d = digits_only(acc)
    if len(d) == 13:
        out.append(f"{d[:4]}-{d[4:8]}-{d[8:12]}-{d[12:13]}")
    if len(d) == 12:
        out.append(f"{d[:3]}-{d[3:5]}-{d[5:11]}-{d[11:12]}")
    return uniq_strs(out)


def jeonbuk_pattern_variants(account_number: str) -> List[str]:
    """전북: 12자리 3-6-3."""
    acc = account_number.strip()
    out = [acc]
    d = digits_only(acc)
    if len(d) == 12:
        out.append(f"{d[:3]}-{d[3:9]}-{d[9:12]}")
    return uniq_strs(out)


def daegu_pattern_variants(account_number: str) -> List[str]:
    """대구: 12자리 3-2-6-1."""
    acc = account_number.strip()
    out = [acc]
    d = digits_only(acc)
    if len(d) == 12:
        out.append(f"{d[:3]}-{d[3:5]}-{d[5:11]}-{d[11:12]}")
    return uniq_strs(out)


def jeju_pattern_variants(account_number: str) -> List[str]:
    """제주: 10자리 2-2-6."""
    acc = account_number.strip()
    out = [acc]
    d = digits_only(acc)
    if len(d) == 10:
        out.append(f"{d[:2]}-{d[2:4]}-{d[4:10]}")
    return uniq_strs(out)


def citi_pattern_variants(account_number: str) -> List[str]:
    """씨티: 12자리 3-6-3."""
    acc = account_number.strip()
    out = [acc]
    d = digits_only(acc)
    if len(d) == 12:
        out.append(f"{d[:3]}-{d[3:9]}-{d[9:12]}")
    return uniq_strs(out)


def kdb_pattern_variants(account_number: str) -> List[str]:
    """KDB산업: 14자리 3-4-4-3."""
    acc = account_number.strip()
    out = [acc]
    d = digits_only(acc)
    if len(d) == 14:
        out.append(f"{d[:3]}-{d[3:7]}-{d[7:11]}-{d[11:14]}")
    return uniq_strs(out)


def sc_pattern_variants(account_number: str) -> List[str]:
    acc = account_number.strip()
    out = [acc]
    d = digits_only(acc)
    if len(d) == 11:
        out.append(f"{d[:3]}-{d[3:5]}-{d[5:11]}")
    return uniq_strs(out)


def hyphen_variant_strings(account_number: str, bank_name: Optional[str]) -> List[str]:
    """extract_account_number 등에서 쓰는 은행별 가상 하이픈 후보(원문 포함, 중복 제거)."""
    if not account_number:
        return []
    acc = account_number.strip()
    if not bank_name:
        return [acc]

    merged: List[str] = []
    bn = bank_name

    if bn in ("농협은행", "부산은행"):
        merged.extend(nonghyup_extended_variants(acc))
    elif bn == "국민은행":
        merged.extend(kb_pattern_variants(acc))
    elif bn == "신한은행":
        merged.extend(shinhan_pattern_variants(acc))
    elif bn == "우리은행":
        merged.extend(woori_pattern_variants(acc))
    elif bn == "하나은행":
        merged.extend(hana_pattern_variants(acc))
    elif bn in ("IBK기업은행", "기업은행"):
        merged.extend(ibk_pattern_variants(acc))
    elif bn == "카카오뱅크":
        merged.extend(kakao_pattern_variants(acc))
    elif bn == "수협은행":
        merged.extend(suhyup_pattern_variants(acc))
    elif bn == "우체국":
        merged.extend(post_office_pattern_variants(acc))
    elif bn == "새마을금고":
        merged.extend(saemaul_pattern_variants(acc))
    elif bn == "전북은행":
        merged.extend(jeonbuk_pattern_variants(acc))
    elif bn == "대구은행":
        merged.extend(daegu_pattern_variants(acc))
    elif bn == "제주은행":
        merged.extend(jeju_pattern_variants(acc))
    elif bn == "씨티은행":
        merged.extend(citi_pattern_variants(acc))
    elif bn == "KDB산업은행":
        merged.extend(kdb_pattern_variants(acc))
    elif bn == "SC제일은행":
        merged.extend(sc_pattern_variants(acc))
    elif bn == "케이뱅크":
        merged.extend(kbank_pattern_variants(acc))
    else:
        merged.append(acc)

    return uniq_strs(merged)
