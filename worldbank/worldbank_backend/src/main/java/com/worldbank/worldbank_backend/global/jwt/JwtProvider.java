package com.worldbank.worldbank_backend.global.jwt;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;

import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.util.Date;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class JwtProvider {

    private final Key key;
    private final long atValidity;
    private final long rtValidity;

    public JwtProvider(
            @Value("${jwt.secret}") String secretKey,
            @Value("${jwt.at-validity}") long atValidity,
            @Value("${jwt.rt-validity}") long rtValidity) {

        // 1. yml에서 가져온 문자열을 보안 키 객체로 변환합니다.
        this.key = Keys.hmacShaKeyFor(secretKey.getBytes(StandardCharsets.UTF_8));
        this.atValidity = atValidity;
        this.rtValidity = rtValidity;
    }

    public String createAccessToken(Long userId, String countryCode) {
        return Jwts.builder()
                .setSubject(userId.toString()) // 유저 ID (Subject)
                .claim("country", countryCode) // 커스텀 클레임 (국가 코드)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + atValidity))
                .signWith(key, SignatureAlgorithm.HS256) // 바이트 배열로 전달
                .compact();
    }

    public String createRefreshToken(Long userId) {
        return Jwts.builder()
                .setSubject(userId.toString())
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + rtValidity))
                .signWith(key, SignatureAlgorithm.HS256)
                .compact();
    }
}
