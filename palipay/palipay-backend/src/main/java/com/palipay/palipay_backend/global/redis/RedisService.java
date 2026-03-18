package com.palipay.palipay_backend.global.redis;

import java.time.Duration;

import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Component;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class RedisService {
    private final StringRedisTemplate redisTemplate;

    // 데이터 가져오기
    public String getData(String key) {
        return redisTemplate.opsForValue().get(key);
    }

    // 데이터 저장 (키, 값, 만료시간)
    public void setDataExpire(String key, String value, long durationMillis) {
        Duration timeout = Duration.ofMillis(durationMillis);
        redisTemplate.opsForValue().set(key, value, timeout);
    }

    // 데이터 삭제
    public void deleteData(String key) {
        redisTemplate.delete(key);
    }
}