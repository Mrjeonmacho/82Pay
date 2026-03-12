package com.palipay.palipay_backend.finance.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.OffsetDateTime;

public record TransferPersistResultDto(
        Long transactionId,
        BigDecimal currentBalance,
        LocalDateTime createdAt
) {
}