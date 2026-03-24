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

# PaddleOCR 한국어 모델을 이미지 빌드 시 한 번 받아 두면, 런타임/재시작마다 재다운로드하지 않음
RUN python -c "from paddleocr import PaddleOCR; PaddleOCR(lang='korean')"

COPY . .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]