package com.palipay.palipay_backend.finance.dto.request;

import com.palipay.palipay_backend.global.bank.BankCode;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;

public record FinanceTransferRequest(
        @NotNull
        Long walletId,

        @NotNull
        @DecimalMin(value = "0.0001")
        BigDecimal amount,

        @NotBlank
        String pinNumber,

        Long workplaceId,

        String description,

        @NotBlank
        String otherAccountNumber,

        @NotBlank
        String otherAccountName,

        @NotNull
        BankCode otherBankCode
) {
}