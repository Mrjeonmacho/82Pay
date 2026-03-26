package com.palipay.palipay_backend.finance.dto.request;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;

public record FinanceAdjustmentRequest(

        @NotNull
        Long walletId,

        @NotBlank
        String pinNumber,

        @NotBlank
        String accountCurrency,

        @NotNull
        @DecimalMin(value = "0")
        BigDecimal convertedAmount,     //보통 krw

        @NotNull
        @DecimalMin(value = "0")
        BigDecimal amount
) {
}
/* TODO
fromcurrency -> 사용자 통화(string, usd, kr...)
toCurrency -> 충전 반영 통화(
amount
 */