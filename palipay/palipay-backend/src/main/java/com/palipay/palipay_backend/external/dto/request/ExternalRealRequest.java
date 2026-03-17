package com.palipay.palipay_backend.external.dto.request;

import lombok.Builder;
import lombok.Getter;
import lombok.ToString;

import java.math.BigDecimal;

@Getter
@Builder
@ToString
public class ExternalRealRequest{
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
