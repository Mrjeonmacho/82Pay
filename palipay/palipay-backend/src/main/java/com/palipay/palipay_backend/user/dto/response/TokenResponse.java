package com.palipay.palipay_backend.user.dto.response;

public record TokenResponse(
        String accessToken,
        String refreshToken,
        String grantType) {
}