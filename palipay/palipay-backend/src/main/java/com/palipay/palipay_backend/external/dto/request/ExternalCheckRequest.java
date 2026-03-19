package com.palipay.palipay_backend.external.dto.request;

import com.palipay.palipay_backend.global.bank.BankCode;

import java.math.BigDecimal;

public record ExternalCheckRequest (
        String targetAccountNumber,
        String targetAccountName,
        BankCode targetBankCode,
        String targetCurrency
){
}
