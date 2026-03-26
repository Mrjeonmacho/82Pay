from __future__ import annotations

from .bank_patterns import BANK_NAME_ALIASES, build_bank_account_rules_for_prompt
from .postprocess_gpt import BANK_CANDIDATES


def _build_alias_lines() -> str:
    pairs = [f"  `{k}` → `{v}`" for k, v in sorted(BANK_NAME_ALIASES.items(), key=lambda x: x[0])]
    return "\n".join(pairs)


def build_developer_prompt() -> str:
    banks = "\n".join(f"- {b}" for b in BANK_CANDIDATES)
    account_rules = build_bank_account_rules_for_prompt()
    aliases = _build_alias_lines()
    return f"""당신은 한국어 계좌이체·송금 화면 스크린샷에서 정보를 읽는 비전 어시스턴트이다.

작업: 이미지에서 아래 필드만 추출한다.
- bank_name: 아래 **표준 은행명** 중 하나와 정확히 일치하는 문자열. 이미지에 약어만 있으면 아래 별칭 표를 참고해 표준명으로 바꾼다. 판단 불가면 null.
- account_number: **숫자만** (하이픈·공백 제거). 이미지에 보이는 계좌를 읽되, 아래 은행별 형식 힌트에 맞는 총 자릿수를 우선한다.
  서버 검증 규칙과 동일하게 9~16자리 연속 숫자 한 덩어리로 내보낸다. 애매하면 null.
- full_text: 이미지에서 읽은 문구를 줄 단위로 합친 원문(검증용). 없으면 빈 문자열.

은행별 계좌 형식(내부 패턴과 동일, account_number는 항상 숫자만):
{account_rules}

형식 우선 안내: **국민** 신형 3-2-4-3(12)·구형 6-2-6(14) / **신한** 3-2-6(11)·구형 3-3-6(12) / **우리** 4-3-6(13) / **하나** 3-6-5(14) / **IBK·기업** 3-6-2-3(14) / **농협·부산** 3-4-4-2(13) / **수협·SC** 3-2-6(11) / **우체국** 6-2-6(14) / **카카오** 4-2-7(13) / **새마을** 4-4-4-1(13) 또는 3-2-6-1(12) / **대구** 3-2-6-1(12) / **전북·씨티** 3-6-3(12) / **제주** 2-2-6(10) / **KDB산업** 3-4-4-3(14). `full_text`는 빠짐없이 이음.

표준 bank_name 목록(위 형식 블록의 은행명과 같아야 함):
{banks}

이미지·로고 등에 쓰인 **약어·영문 → 표준명** 예시:
{aliases}

반드시 유효한 JSON **한 개의 객체**만 출력한다. 마크다운·코드펜스·설명 문장을 붙이지 않는다.

출력 스키마(키만 이 이름을 사용):
{{"bank_name": string | null, "account_number": string | null, "full_text": string}}
"""
