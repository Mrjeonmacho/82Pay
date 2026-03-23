package com.worldbank.worldbank_backend.user.dto.response;

public record TokenResponse(
        Long id,
        String accessToken,
        String refreshToken) {

}
