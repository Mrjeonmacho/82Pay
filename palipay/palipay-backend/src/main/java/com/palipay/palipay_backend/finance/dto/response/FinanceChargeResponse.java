package com.palipay.palipay_backend.finance.dto.response;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record FinanceChargeResponse(

        String message,
        FinanceChargeData data

) {
    public record FinanceChargeData(

            Long transactionId,
            BigDecimal chargedAmount,
            BigDecimal exchangeRate,
            BigDecimal currentBalance,
            LocalDateTime createdAt

    ) {
    }

    public static FinanceChargeResponse success(
            Long transactionId,
            BigDecimal chargeAmount,
            BigDecimal exchangeRate,
            BigDecimal currentBalance,
            LocalDateTime createdAt
    ){
        return new FinanceChargeResponse(
                "충전이 완료되었습니다.",
                new FinanceChargeData(
                        transactionId,
                        chargeAmount,
                        exchangeRate,
                        currentBalance,
                        createdAt
                )
        );
    }
}