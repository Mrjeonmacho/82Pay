package com.palipay.palipay_backend.finance.dto.request;

import jakarta.validation.constraints.NotBlank;

import java.math.BigDecimal;

public record ExAccValidateRequest(
        @NotBlank
        String otherAccountNumber,


        String otherAccountName,


        String otherBankCode,

        BigDecimal amount,

        @NotBlank
        String accountCurrency,

        String pinNumber
) {
}
