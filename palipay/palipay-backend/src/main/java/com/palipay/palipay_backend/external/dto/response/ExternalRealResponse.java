package com.palipay.palipay_backend.external.dto.response;

import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;

@Getter
@Builder
public class ExternalRealResponse {
    private String message;

    private String senderAccountNumber;
    private String senderAccountName;
    private String senderBankcode;

    private String targetAccountNumber;
    private String targetAccountName;
    private String targetBankcode;

    private BigDecimal senderAmount;
    private BigDecimal targetAmount;

    private String senderCurrency;
    private String targetCurrency;
}
