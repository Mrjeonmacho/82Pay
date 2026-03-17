package com.palipay.palipay_backend.user.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record JoinRequest(
        @NotBlank @Email String email,
        @NotBlank String password,
//        @NotBlank String name,
        @NotBlank String countryCode,
        @NotBlank String name,
        @NotBlank String phoneNumber
) {
}
