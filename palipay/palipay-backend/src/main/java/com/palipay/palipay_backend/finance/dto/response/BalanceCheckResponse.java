package com.palipay.palipay_backend.finance.dto.response;

import java.math.BigDecimal;

public record BalanceCheckResponse(
        Boolean isSufficient,
        BigDecimal currentBalance,
        BigDecimal requiredAmount,
        BigDecimal shortageAmount
){
    public static BalanceCheckResponse sufficient(
            BigDecimal currentBalance,
            BigDecimal requiredAmount
    ) {
        return new BalanceCheckResponse(
                true,
                currentBalance,
                requiredAmount,
                null
        );
    }

    public static BalanceCheckResponse insufficient(
            BigDecimal currentBalance,
            BigDecimal requiredAmount,
            BigDecimal shortageAmount
    ) {
        return new BalanceCheckResponse(
                false,
                currentBalance,
                requiredAmount,
                shortageAmount
        );
    }
}
