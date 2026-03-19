package com.palipay.palipay_backend.user.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.palipay.palipay_backend.user.dto.request.EmailCheckRequest;
import com.palipay.palipay_backend.user.dto.request.EmailVerificationRequest;
import com.palipay.palipay_backend.user.dto.request.JoinRequest;
import com.palipay.palipay_backend.user.dto.request.LoginRequest;
import com.palipay.palipay_backend.user.dto.response.TokenResponse;
import com.palipay.palipay_backend.user.service.UserAuthService;
import com.palipay.palipay_backend.user.service.UserJoinService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

import java.util.HashMap;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

@RestController
@RequestMapping("/api/user")
@RequiredArgsConstructor
public class UserAuthController {

    private final UserJoinService userJoinService;
    private final UserAuthService userAuthService;

    // 1. 이메일 중복 체크 (프론트 onChange/onBlur용)
    @GetMapping("/check")
    public ResponseEntity<Map<String, Object>> checkEmail(
            @RequestParam("type") String type,
            @RequestParam("value") String value) {
        // 사용 가능하면 true, 중복이면 false 반환
        boolean isEmailAvailable = userJoinService.isEmailAvailable(type, value);
        Map<String, Object> response = new HashMap<>();
        response.put("isEmailAvailable", isEmailAvailable);

        if (isEmailAvailable) {
            return ResponseEntity.ok(response); // 200 OK
        } else {
            response.put("message", "이미 존재하는 " + type + "입니다.");
            return ResponseEntity.status(HttpStatus.OK).body(response);
        }
    }

    // 2. 인증 코드 발송 (Next 버튼 클릭 시)
    @PostMapping("/email/code")
    public ResponseEntity<Void> sendCode(@Valid @RequestBody EmailCheckRequest request) {
        userJoinService.sendAuthCode(request.email());
        return ResponseEntity.ok().build();
    }

    // 3. 인증 코드 검증 (인증확인 버튼 클릭 시)
    @PostMapping("/email/verification")
    public ResponseEntity<Boolean> verifyCode(@Valid @RequestBody EmailVerificationRequest request) {
        boolean isVerified = userJoinService.verifyCode(request.email(), request.authCode());
        return ResponseEntity.ok(isVerified);
    }

    // 4. 회원가입 완료
    @PostMapping("/signup")
    public ResponseEntity<?> join(@Valid @RequestBody JoinRequest request) {
        return userJoinService.join(request);
    }

    // 로그인
    @PostMapping("/login")
    public ResponseEntity<TokenResponse> login(@Valid @RequestBody LoginRequest request) {
        TokenResponse response = userAuthService.login(request);
        return ResponseEntity.ok(response);
    }

}
