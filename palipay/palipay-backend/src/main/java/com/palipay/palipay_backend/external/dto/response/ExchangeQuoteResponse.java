package com.palipay.palipay_backend.external.dto.response;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record ExchangeQuoteResponse(
        String message,
        Data data
) {
    public record Data(
            BigDecimal exchangeRate,
            LocalDateTime rateTimestamp
    ) {
    }
}