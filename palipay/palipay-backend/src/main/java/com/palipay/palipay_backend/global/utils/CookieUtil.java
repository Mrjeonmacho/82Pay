package com.palipay.palipay_backend.global.utils;

import org.springframework.http.HttpHeaders;

import org.springframework.http.ResponseCookie;
import org.springframework.stereotype.Component;

import com.palipay.palipay_backend.global.security.JwtProvider;

import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class CookieUtil {

    private final JwtProvider jwtProvider;

    // Refresh Token 쿠키 설정
    public void setRefreshTokenCookie(HttpServletResponse response, String refreshToken) {
        ResponseCookie cookie = ResponseCookie.from("refreshToken", refreshToken)
                .path("/")
                .httpOnly(true)
                .secure(true) // HTTPS 사용 시 true (로컬 테스트 시 주의)
                .sameSite("Lax")
                .maxAge(jwtProvider.getRefreshExpirationTime() / 1000)
                .build();

        response.addHeader(HttpHeaders.SET_COOKIE, cookie.toString());
    }

    // 쿠키 삭제 (로그아웃용)
    public void deleteRefreshTokenCookie(HttpServletResponse response) {
        ResponseCookie cookie = ResponseCookie.from("refreshToken", "")
                .path("/")
                .httpOnly(true)
                .secure(true)
                .maxAge(0) // 즉시 만료
                .build();

        response.addHeader(HttpHeaders.SET_COOKIE, cookie.toString());
    }

}
