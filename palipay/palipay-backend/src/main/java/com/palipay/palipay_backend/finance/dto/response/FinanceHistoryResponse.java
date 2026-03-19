package com.palipay.palipay_backend.finance.dto.response;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.util.List;

public record FinanceHistoryResponse(
        String message,
        FinanceHistoryData data
) {
    public record FinanceHistoryData(
            List<FinanceHistoryItem> items,
            FinanceHistoryPage page
    ) {
    }

    public record FinanceHistoryItem(
            Long transactionId,
            String category,
            BigDecimal amount,
            BigDecimal exchangeAfterAmount,
            BigDecimal exchangeRate,
            String otherAccountNumber,
            String otherAccountName,
            String otherBankCode,
            Long workplaceId,
            LocalDateTime createdAt,
            String description
    ) {
    }

    public record FinanceHistoryPage(
            Integer page,
            Integer size,
            Long totalElements,
            Integer totalPages
    ) {
    }
}