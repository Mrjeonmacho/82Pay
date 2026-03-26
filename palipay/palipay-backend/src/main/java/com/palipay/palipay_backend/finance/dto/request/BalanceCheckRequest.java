package com.palipay.palipay_backend.finance.dto.request;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;

public record BalanceCheckRequest(
        @NotNull
        Long walletId,

        @NotNull
        @DecimalMin(value = "0", inclusive = true)
        BigDecimal amount
){
}
