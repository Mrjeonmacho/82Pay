package com.palipay.palipay_backend.external.dto.request;

import com.palipay.palipay_backend.global.bank.BankCode;

import java.math.BigDecimal;

public record ExternalTransferRequest(
        String senderAccountNumber,
        String senderAccountName,
        BankCode senderBankCode,
        BigDecimal senderAmount,
        String senderCurrency,

        String targetAccountNumber,
        String targetAccountName,
        BankCode targetBankCode,
        BigDecimal targetAmount,
        String targetCurrency,

        String description
) {
}