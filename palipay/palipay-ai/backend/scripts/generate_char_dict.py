# backend/scripts/generate_char_dict.py

import os

OUTPUT_PATH = os.path.join(
    os.path.dirname(__file__),
    "..",
    "ocr_assets",
    "char_dict.txt"
)

os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)

with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
    # ==========================
    # 1. 숫자
    # ==========================
    for i in range(10):
        f.write(f"{i}\n")

    # ==========================
    # 2. 영어 대소문자
    # ==========================
    for c in "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz":
        f.write(f"{c}\n")

    # ==========================
    # 3. 특수문자 (계좌/영수증)
    # ==========================
    special_chars = [
        ".", ",", ":", ";", "-", "_", "/", "\\",
        "(", ")", "[", "]", "{", "}",
        "@", "#", "$", "%", "&", "*", "+", "=",
        "?", "!", "\"", "'", "~", "`", "<", ">", "|",
        "₩", "℃"
    ]

    for c in special_chars:
        f.write(f"{c}\n")

    # ==========================
    # 4. 한글 완성형 (가 ~ 힣)
    # ==========================
    for code in range(0xAC00, 0xD7A4):
        f.write(f"{chr(code)}\n")

print("char_dict.txt 생성 완료:", OUTPUT_PATH)