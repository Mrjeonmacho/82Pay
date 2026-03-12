package com.palipay.palipay_backend.finance.dto;

import java.math.BigDecimal;

public record TransferResultCacheDto(
        String transferId,
        Long transactionId,
        String status,
        BigDecimal currentBalance,
        String createdAt
) {
}