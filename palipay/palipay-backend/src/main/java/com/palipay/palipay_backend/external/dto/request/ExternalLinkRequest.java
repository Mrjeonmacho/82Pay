package com.palipay.palipay_backend.external.dto.request;

public record ExternalLinkRequest(
        String targetAccountNumber,
        String targetAccountPassword,
        String targetCurrency
) {
}
