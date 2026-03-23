package com.palipay.palipay_backend.finance.dto.request;

public record FinanceAccountRequest(
        Long walletId,
        String bankCode,
        String accountNumber,
        String accountUsername,
        String accountPassword,
        String moneyCode
) {
}
