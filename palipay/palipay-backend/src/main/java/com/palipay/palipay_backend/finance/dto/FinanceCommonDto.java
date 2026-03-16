package com.palipay.palipay_backend.finance.dto;

import com.palipay.palipay_backend.finance.domain.TransactionCategory;
import com.palipay.palipay_backend.global.bank.BankCode;

import java.math.BigDecimal;

public record FinanceCommonDto(

        String sourceAccountNumber,
        String sourceAccountName,
        BankCode sourceBankCode,
        BigDecimal sourceAmount,
        String sourceCurrency,

        String targetAccountNumber,
        String targetAccountName,
        BankCode targetBankCode,
        BigDecimal targetAmount,
        String targetCurrency,

        String description,

        TransactionCategory transactionCategory
) {
}