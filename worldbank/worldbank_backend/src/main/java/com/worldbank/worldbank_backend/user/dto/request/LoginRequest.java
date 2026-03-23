package com.worldbank.worldbank_backend.user.dto.request;

public record LoginRequest(
        String email,
        String password) {
}
