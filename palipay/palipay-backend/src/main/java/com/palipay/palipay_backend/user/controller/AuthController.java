package com.palipay.palipay_backend.user.controller;

import java.nio.file.attribute.UserPrincipal;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.CookieValue;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.palipay.palipay_backend.global.utils.CookieUtil;
import com.palipay.palipay_backend.user.dto.request.LoginRequest;
import com.palipay.palipay_backend.user.dto.request.PasswordCheckRequest;
import com.palipay.palipay_backend.user.dto.request.PasswordUpdateRequest;
import com.palipay.palipay_backend.user.dto.response.LoginResponse;
import com.palipay.palipay_backend.user.dto.response.TokenResponse;
import com.palipay.palipay_backend.user.service.UserAuthService;

import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final UserAuthService userAuthService;
    private final CookieUtil cookieUtil;

    // 로그인
    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@Valid @RequestBody LoginRequest request, HttpServletResponse response) {
        TokenResponse tokenResponse = userAuthService.login(request);
        cookieUtil.setRefreshTokenCookie(response, tokenResponse.refreshToken()); // 봉투에 쿠키 넣기
        return ResponseEntity.ok(new LoginResponse(tokenResponse.accessToken(), "Bearer")); // 바디엔 AT만
    }

    // 로그아웃
    @PostMapping("/logout")
    public ResponseEntity<String> logout(@RequestHeader("Authorization") String accessToken,
            HttpServletResponse response) {
        userAuthService.logout(accessToken);
        // 로그아웃 시 쿠키도 즉시 만료시킴
        cookieUtil.deleteRefreshTokenCookie(response);
        return ResponseEntity.ok("Successfully logged out.");
    }

    // 토큰 재발급
    @PostMapping("/refresh")
    public ResponseEntity<LoginResponse> refreshToken(
            @CookieValue(name = "refreshToken") String refreshToken,
            HttpServletResponse response) {

        // 서비스 로직에서 이제 authHeader 파싱 대신 순수 refreshToken 문자열을 받게 수정됨
        TokenResponse tokenResponse = userAuthService.reissue(refreshToken);

        // 새로 발급된 RT를 다시 쿠키에 저장 (Refresh Token Rotation)
        cookieUtil.setRefreshTokenCookie(response, tokenResponse.refreshToken());

        // 응답 바디에는 새로운 AT만 담아서 반환
        return ResponseEntity.ok(new LoginResponse(tokenResponse.accessToken(), "Bearer"));
    }

    // 비밀번호 변경
    @PatchMapping("/password")
    public ResponseEntity<String> updatePassword(
            @AuthenticationPrincipal Long userId, // spring security 가 갖고 있는 유저 정보
            @Valid @RequestBody PasswordUpdateRequest request,
            HttpServletResponse response) {

        userAuthService.updatePassword(userId, request);
        cookieUtil.deleteRefreshTokenCookie(response);
        return ResponseEntity.ok("비밀번호가 성공적으로 변경되었습니다.");
    }

    @PostMapping("/password-check")
    public ResponseEntity<Boolean> checkPassword(
            @AuthenticationPrincipal Long userId,
            @Valid @RequestBody PasswordCheckRequest request) {

        boolean isCorrect = userAuthService.checkCurrentPassword(userId, request);
        return

        ResponseEntity.ok(isCorrect);
    }

}
