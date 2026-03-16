package com.palipay.palipay_backend.external.dto.response;


import java.math.BigDecimal;

public record ExternalTransferResponse(
        String message,
        ExternalTransferResponse.TransferData data,
        ExternalTransferResponse.TransferError error
) {
    public boolean success() {
        return data() != null && error() == null;
    }

    public record TransferData(
            String senderAccountNumber,
            String senderAccountName,
            String senderBankCode,
            BigDecimal senderAmount,
            String targetAccountNumber,
            String targetAccountName,
            String targetBankCode,
            BigDecimal targetAmount,
            String targetCurrency,
            String senderCurrency
    ) {}

    public record TransferError(
            String code,
            String details
    ) {}
    public static ExternalTransferResponse success(String message, ExternalTransferResponse.TransferData data) {
        return new ExternalTransferResponse(message, data, null);
    }

    public static ExternalTransferResponse fail(String message, String code, String details) {
        return new ExternalTransferResponse(
                message,
                null,
                new ExternalTransferResponse.TransferError(code, details)
        );
    }
}