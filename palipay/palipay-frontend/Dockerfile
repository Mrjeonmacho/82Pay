# --- 1단계: 플러터 빌드 환경 ---
# 최신 안정화 버전의 플러터 이미지를 사용합니다.
FROM ghcr.io/cirruslabs/flutter:stable AS builder

# 작업 디렉토리 설정
WORKDIR /app

# 패키지 의존성 파일 먼저 복사 및 다운로드 (도커 캐시 최적화)
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# 폰트를 포함한 소스 코드 전체 복사
COPY . .

# 플러터 웹 릴리즈 모드로 빌드
RUN flutter build web --release

# --- 2단계: Nginx 서빙 환경 ---
# 가장 가벼운 Nginx 알파인 이미지 사용
FROM nginx:alpine

# 유저가 작성한 Nginx 설정 파일 덮어쓰기
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 1단계(builder)에서 완성된 웹 결과물만 Nginx 서빙 폴더로 복사
COPY --from=builder /app/build/web /usr/share/nginx/html

# 💡 핵심 추가: Nginx가 숨김 파일(.env)을 읽을 수 있도록 모든 사용자에게 읽기 권한(644) 부여
RUN chmod 644 /usr/share/nginx/html/assets/.env

# 80번 포트 개방
EXPOSE 80

# Nginx 실행
CMD ["nginx", "-g", "daemon off;"]