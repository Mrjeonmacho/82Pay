package com.palipay.palipay_backend.finance.dto.response;

import java.math.BigDecimal;

public record FinanceTransferResponse(
        String message,
        Data data
) {
    public record Data(
            String transferId,
            Long transactionId,
            String status,
            BigDecimal currentBalance,
            String createdAt
    ) {
    }

    public static FinanceTransferResponse success(
            String transferId,
            Long transactionId,
            BigDecimal currentBalance,
            String createdAt
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