package com.palipay.palipay_backend.user.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public record JoinRequest(
                @NotBlank @Email String email,
                @Pattern(regexp = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[@$!%*#?&])[A-Za-z\\d@$!%*#?&]{8,}$") @NotBlank String password,
                // @NotBlank String name,
                @NotBlank String countryCode,
                @NotBlank String name,
                @NotBlank String phoneNumber) {
}
