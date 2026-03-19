package com.palipay.palipay_backend.external.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record ExchangeRateCacheDto (
        String currencyPair,
        String date,
        BigDecimal rate,
        LocalDateTime fetchedAt
){
}
