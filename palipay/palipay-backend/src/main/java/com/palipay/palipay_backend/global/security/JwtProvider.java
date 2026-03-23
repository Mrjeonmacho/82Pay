package com.palipay.palipay_backend.global.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.MalformedJwtException;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.UnsupportedJwtException;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value; // 체크!
import org.springframework.stereotype.Component;

import com.palipay.palipay_backend.user.dto.response.TokenResponse;

import java.security.Key;
import java.util.Date;

@Component
@Slf4j
public class JwtProvider {

    private final Key key;
    private final long accessTokenExpiration;
    private final long refreshTokenExpiration;

    public JwtProvider(
            @Value("${jwt.secret}") String secretKey,
            @Value("${jwt.access-token-expiration}") long accessTokenExpiration,
            @Value("${jwt.refresh-token-expiration}") long refreshTokenExpiration) {

        byte[] keyBytes = Decoders.BASE64.decode(secretKey);
        this.key = Keys.hmacShaKeyFor(keyBytes);
        this.accessTokenExpiration = accessTokenExpiration;
        this.refreshTokenExpiration = refreshTokenExpiration;
    }

    // token 생성
    public TokenResponse generateToken(Long userId) {
        long now = System.currentTimeMillis();
        Date accessTokenExpiredAt = new Date(now + accessTokenExpiration);
        Date refreshTokenExpiredAt = new Date(now + refreshTokenExpiration);

        // 1. AccessToken 생성
        String accessToken = Jwts.builder()
                .setSubject(userId.toString())
                .setIssuedAt(new Date(now)) // 발행시간
                .setExpiration(accessTokenExpiredAt) // 만료시간
                .signWith(key, SignatureAlgorithm.HS256)
                .compact();

        // 2. refreshToken 생성
        String refreshToken = Jwts.builder()
                .setSubject(userId.toString())
                .setIssuedAt(new Date(now))
                .setExpiration(refreshTokenExpiredAt)
                .signWith(key, SignatureAlgorithm.HS256)
                .compact();

        return new TokenResponse(accessToken, refreshToken, "Bearer");
    }

    // 토큰에서 유저 아이디만 추출
    public Long getUserId(String token) {
        Claims claims = parseClaims(token);
        return Long.parseLong(claims.getSubject());
    }

    // 토큰에서 클레임 추출
    // 토큰이 만료되었더라도 클레임은 반환 (자연스러운 토큰 재발급 위함)
    private Claims parseClaims(String token) {
        try {
            return Jwts.parserBuilder()
                    .setSigningKey(key)
                    .build()
                    .parseClaimsJws(token)
                    .getBody();
        } catch (ExpiredJwtException e) {
            // 만료된 토큰이라도 그 안에 들어있는 유저 ID(Subject)는 알아야 Redis에서 기존 토큰을 찾아 비교할 수 있음
            return e.getClaims();
        }
    }

    // 토큰 유효성 검증 (True/False만 반환)
    public boolean validateToken(String token) {
        try {
            Jwts.parserBuilder()
                    .setSigningKey(key)
                    .build()
                    .parseClaimsJws(token);
            return true;
        } catch (io.jsonwebtoken.security.SecurityException | MalformedJwtException e) {
            log.info("잘못된 JWT 서명입니다.");
        } catch (ExpiredJwtException e) {
            log.info("만료된 JWT 토큰입니다.");
        } catch (UnsupportedJwtException e) {
            log.info("지원되지 않는 JWT 토큰입니다.");
        } catch (IllegalArgumentException e) {
            log.info("JWT 토큰이 잘못되었습니다.");
        }
        return false;
    }

    // 토큰 만료 시간 추출 (앞으로 몇 초 뒤에 수명이 다하는가?)
    public long getExpiration(String token) {
        Date expiration = parseClaims(token).getExpiration();
        long now = System.currentTimeMillis();
        return (expiration.getTime() - now);
    }

    // 새로 만들 토큰에 부여할 수명
    public long getRefreshExpirationTime() {
        return refreshTokenExpiration;
    }

}