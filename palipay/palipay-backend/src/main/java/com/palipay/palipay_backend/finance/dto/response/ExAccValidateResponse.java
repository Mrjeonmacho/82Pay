package com.palipay.palipay_backend.finance.dto.response;

import java.math.BigDecimal;

public record ExAccValidateResponse(
        Boolean isValid,
        BigDecimal maxAmount,
        Long workplaceId,
        String accountName,
        String message
) {
}
