package com.palipay.palipay_backend.finance.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record TransferResultCacheDto(
        String transferId,
        Long transactionId,
        String status,
        BigDecimal currentBalance,
        LocalDateTime createdAt
) {
}