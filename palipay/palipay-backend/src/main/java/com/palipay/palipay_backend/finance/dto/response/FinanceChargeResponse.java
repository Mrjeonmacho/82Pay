package com.palipay.palipay_backend.finance.dto.response;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.OffsetDateTime;

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
}