package com.palipay.palipay_backend.finance.dto;

public record ExternalTransferResultDto(
        boolean success,
        String externalTransactionId,
        String status,
        String rawResponse
) {

    public static ExternalTransferResultDto success(
            String externalTransactionId,
            String rawResponse
    ) {
        return new ExternalTransferResultDto(
                true,
                externalTransactionId,
                "SUCCESS",
                rawResponse
        );
    }

    public static ExternalTransferResultDto failed(
            String externalTransactionId,
            String rawResponse
    ) {
        return new ExternalTransferResultDto(
                false,
                externalTransactionId,
                "FAILED",
                rawResponse
        );
    }
}