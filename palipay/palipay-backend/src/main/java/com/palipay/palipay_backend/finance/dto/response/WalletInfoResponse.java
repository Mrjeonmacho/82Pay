package com.palipay.palipay_backend.finance.dto.response;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record WalletInfoResponse(
        String message,
        Data data
) {
    public record Data(
            Long walletId,
            Long userId,
            String accountNumber,
            String moneyCode,
            String accountUsername,
            String bankCode,
            BigDecimal amount,
            String pinNumber,
            LocalDateTime createdAt,
            LocalDateTime updatedAt
    ) {
    }
}