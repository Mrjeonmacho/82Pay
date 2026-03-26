package com.palipay.palipay_backend.user.dto.response;

public record LoginResponse(
                String accessToken,
                String grantType,
                UserInfo userInfo) {
        public LoginResponse(String accessToken, String grantType) {
                this(accessToken, grantType, null);
        }

        public record UserInfo(
                        Long userId,
                        String name,
                        String email,
                        String countryCode) {
        }
}