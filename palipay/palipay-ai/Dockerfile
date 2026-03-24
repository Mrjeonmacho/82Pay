FROM python:3.10

WORKDIR /app

RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Pod 재시작 시마다 빈 디스크가 되므로, 런타임이 아니라 이미지 빌드 때 캐시에 모델을 넣어 둠
RUN python -c "from paddleocr import PaddleOCR; PaddleOCR(lang='korean')" && \
    python -c "import easyocr; easyocr.Reader(['ko', 'en'])"

COPY . .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]