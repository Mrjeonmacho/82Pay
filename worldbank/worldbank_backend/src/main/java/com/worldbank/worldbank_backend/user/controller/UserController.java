package com.worldbank.worldbank_backend.user.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseCookie;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.worldbank.worldbank_backend.global.utils.CookieUtil;
import com.worldbank.worldbank_backend.user.dto.request.LoginRequest;
import com.worldbank.worldbank_backend.user.dto.request.SignupRequest;
import com.worldbank.worldbank_backend.user.dto.response.LoginResponse;
import com.worldbank.worldbank_backend.user.dto.response.TokenResponse;
import com.worldbank.worldbank_backend.user.service.UserService;

import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/user")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;
    private final CookieUtil cookieUtil;

    @PostMapping("/signup")
    public ResponseEntity<String> signup(@RequestBody SignupRequest request) {
        userService.signUp(request);
        return ResponseEntity.ok("회원가입 성공");
    }

    @GetMapping("/check")
    public ResponseEntity<Boolean> checkDuplication(
            @RequestParam("type") String type,
            @RequestParam("value") String value) {

        boolean isDuplicate = userService.isEmailDuplicate(value);
        if (isDuplicate) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(false);
        }

        return ResponseEntity.ok(true);
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(
            @RequestBody LoginRequest loginRequest,
            HttpServletResponse response) {

        // 1. 서비스에서 토큰 데이터(ID, AT, RT) 가져오기
        TokenResponse tokenResponse = userService.login(loginRequest);

        // 2. CookieUtil을 사용해 Refresh Token 쿠키 생성 및 헤더에 추가
        cookieUtil.createRefreshTokenCookie(response, tokenResponse.refreshToken());

        // 3. 바디에는 LoginResponse 반환
        return ResponseEntity.ok(new LoginResponse(
                tokenResponse.id(),
                tokenResponse.accessToken()));
    }

}
