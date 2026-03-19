package com.palipay.palipay_backend.external.dto.response;

import java.math.BigDecimal;

public record ExternalCheckResponse (
        String message,
        BigDecimal amount,
        String currency
){
}
