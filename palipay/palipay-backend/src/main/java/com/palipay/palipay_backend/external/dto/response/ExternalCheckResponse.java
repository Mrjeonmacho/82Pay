package com.palipay.palipay_backend.external.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.math.BigDecimal;

public record ExternalCheckResponse (
        @JsonProperty("check") Boolean success,
        String message,
        BigDecimal amount,
        String currency,
        String accountName
){
}
