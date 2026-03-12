package com.palipay.palipay_backend.external.dto.response;


public record ExternalTransferResponse(
        boolean success,
        String status,
        String message,
        String rawResponse
) {
}