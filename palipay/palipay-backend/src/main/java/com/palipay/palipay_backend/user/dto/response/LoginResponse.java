package com.palipay.palipay_backend.user.dto.response;

public record LoginResponse(
        String accessToken,
        String grantType
// UserInfo user // ⭐️ 사용자 정보 묶음
) {
    // public record UserInfo(
    // Long userId,
    // String name,
    // String email,
    // Long walletBalance, // 메인 화면에 바로 보여줄 잔액
    // String nationality // 국적 등
    // ) {}
}