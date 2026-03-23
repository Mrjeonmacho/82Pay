package com.worldbank.worldbank_backend.global.redis;

import org.springframework.data.redis.core.RedisHash;

import jakarta.persistence.Id;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@RedisHash(value = "refreshToken", timeToLive = 604800) // 7일(초 단위)
public class RefreshToken {

    @Id // Redis의 Key가 될 부분 (userId가 들어감)
    private String id;

    private String refreshToken;

    public RefreshToken(String countryCode, Long userId, String refreshToken) {
        this.id = countryCode + userId; // 여기서 국가와 ID를 섞음
        this.refreshToken = refreshToken;
    }
}