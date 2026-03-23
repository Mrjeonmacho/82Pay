package com.worldbank.worldbank_backend.user.strategy;

import java.util.Optional;

import com.worldbank.worldbank_backend.user.dto.request.SignupRequest;
import com.worldbank.worldbank_backend.user.entity.BaseUser;

public interface UserStrategy {
    String getCountryCode(); // "KR", "US", "JP", "CH" 중 하나 반환

    // 회원가입
    void signup(SignupRequest request, String encodedPassword);

    // 이메일 중복 검사
    boolean existsByEmail(String email);

    // 로그인
    Optional<? extends BaseUser> findByEmail(String email);
    // void resetPassword(String email, String newPassword);
}
