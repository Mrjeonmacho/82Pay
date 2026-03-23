package com.worldbank.worldbank_backend.user.dto.response;

public record LoginResponse(
        Long userId,
        String accessToken) {
}
