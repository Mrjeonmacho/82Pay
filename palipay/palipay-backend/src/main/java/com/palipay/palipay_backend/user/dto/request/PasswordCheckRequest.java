package com.palipay.palipay_backend.user.dto.request;

import jakarta.validation.constraints.NotBlank;

public record PasswordCheckRequest(
        @NotBlank String password) {

}
