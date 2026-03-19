package com.palipay.palipay_backend.finance.dto.request;

import jakarta.validation.constraints.NotBlank;

import java.math.BigDecimal;

public record ExAccValidateRequest(
        @NotBlank
        String otherAccountNumber,

        @NotBlank
        String otherAccountName,

        @NotBlank
        String otherBankCode,

        BigDecimal amount,

        String accountCurrency,

        String pinNumber
) {
}
