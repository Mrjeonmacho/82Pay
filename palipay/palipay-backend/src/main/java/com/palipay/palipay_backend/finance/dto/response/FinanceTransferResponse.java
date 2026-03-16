package com.palipay.palipay_backend.finance.dto.response;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record FinanceTransferResponse(
        String message,
        Data data
) {
    public record Data(
            String transferId,
            Long transactionId,
            String status,
            BigDecimal currentBalance,
            LocalDateTime createdAt
    ) {
    }

    public static FinanceTransferResponse success(
            String transferId,
            Long transactionId,
            BigDecimal currentBalance,
            LocalDateTime createdAt
    ) {
        return new FinanceTransferResponse(
                "이체가 완료되었습니다.",
                new Data(
                        transferId,
                        transactionId,
                        "SUCCESS",
                        currentBalance,
                        createdAt
                )
        );
    }
}