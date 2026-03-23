package com.worldbank.worldbank_backend.user.strategy;

import com.worldbank.worldbank_backend.user.dto.request.SignupRequest;

public interface UserStrategy {
    String getCountryCode(); // "KR", "US", "JP", "CH" 중 하나 반환

    // 회원가입
    void signup(SignupRequest request, String encodedPassword);

    // 이메일 중복 검사
    boolean existsByEmail(String email);

    // 로그인/로그아웃/비번찾기
    // 로그인은 보통 시큐리티가 처리하지만, DB 조회 로직은 전략에서 제공
    // Optional<? extends Object> findByEmail(String email);
    // void resetPassword(String email, String newPassword);
}
