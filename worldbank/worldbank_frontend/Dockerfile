# --- 1단계: 플러터 빌드 환경 ---
FROM ghcr.io/cirruslabs/flutter:stable AS builder

# 혹시 모를 권한 충돌을 방지하기 위해 root 권한으로 실행
USER root

# 작업 디렉토리 설정
WORKDIR /app

# 1. Git 보안 정책 우회 (가장 핵심적인 해결책)
# Jenkins에서 복사해 온 파일들의 소유권 문제로 git이 멈추는 것을 방지합니다.
RUN git config --global --add safe.directory '*'

# 2. Flutter 텔레메트리 비활성화
# CI/CD 등 터미널 입력이 불가능한 환경에서 통계 수집 동의를 묻다가 멈추는 현상을 방지합니다.
RUN flutter config --no-analytics

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

RUN chmod 644 /usr/share/nginx/html/assets/.env

# 80번 포트 개방
EXPOSE 80

# Nginx 실행
CMD ["nginx", "-g", "daemon off;"]