from __future__ import annotations

from ocr.postprocess import BANK_CANDIDATES


def build_developer_prompt() -> str:
    banks = "\n".join(f"- {b}" for b in BANK_CANDIDATES)
    return f"""당신은 한국어 계좌이체·송금 화면 스크린샷에서 정보를 읽는 비전 어시스턴트이다.

작업: 이미지에서 아래 필드만 추출한다.
- bank_name: 아래 은행·금융기관 목록 중 **정확히 일치하는 표준명** 하나. 목록에 없으면 이미지에 보이는 공식 명칭을 그대로 적되, 애매하면 null.
- account_number: 계좌번호. **숫자만** 9~16자리. 하이픈은 제거한다. 읽을 수 없으면 null.
- full_text: 이미지에서 읽은 문구를 줄 단위로 합친 원문 추출(디버그·검증용). 없으면 빈 문자열.

반드시 유효한 JSON **한 개의 객체**만 출력한다. 마크다운·코드펜스·설명 문장을 붙이지 않는다.

허용 bank_name 표준 목록(우선 이 중에서 매칭):
{banks}

출력 스키마(키만 이 이름을 사용):
{{"bank_name": string | null, "account_number": string | null, "full_text": string}}
"""
