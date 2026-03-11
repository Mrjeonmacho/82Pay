FROM gradle:7.6-jdk17-alpine AS builder
WORKDIR /app

# 현재 폴더의 모든 소스 코드를 도커 내부로 복사
COPY . .

# gradlew 실행 권한 부여 및 빌드 (테스트 제외로 속도 향상)
RUN chmod +x ./gradlew
RUN ./gradlew clean build -x test --no-daemon

# 무거운 JDK 대신 실행 전용인 JRE만 가져와서 용량 대폭 감소
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# 결제/금융 서비스 필수: 타임존을 KST(한국 시간)로 강제 고정
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Asia/Seoul /etc/localtime && \
    echo "Asia/Seoul" > /etc/timezone

# (plain.jar와 충돌하지 않도록 -SNAPSHOT.jar만 지정)
COPY --from=builder /app/build/libs/*-SNAPSHOT.jar app.jar

# 젠킨스가 넣어준 환경변수나 시크릿을 쓸 수 있게 준비
EXPOSE 8080
ENV SPRING_PROFILES_ACTIVE=prod

# 스프링 부트 실행 (자바 옵션으로 타임존 한 번 더 조치)
ENTRYPOINT ["java", "-Duser.timezone=Asia/Seoul", "-jar", "app.jar"]