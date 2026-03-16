package com.palipay.palipay_backend.finance.dto.response;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record FinanceAdjustmentResponse(

        String message,
        FinanceChargeData data

) {
    public record FinanceChargeData(

            Long transactionId,
            BigDecimal afterAmount,
            BigDecimal exchangeRate,
            BigDecimal currentBalance,
            LocalDateTime createdAt

    ) {
    }

    public static FinanceAdjustmentResponse success(
            Long transactionId,
            BigDecimal afterAmount,
            BigDecimal exchangeRate,
            BigDecimal currentBalance,
            LocalDateTime createdAt
    ){
        return new FinanceAdjustmentResponse(
                "거래가 완료되었습니다.",
                new FinanceChargeData(
                        transactionId,
                        afterAmount,
                        exchangeRate,
                        currentBalance,
                        createdAt
                )
        );
    }
}