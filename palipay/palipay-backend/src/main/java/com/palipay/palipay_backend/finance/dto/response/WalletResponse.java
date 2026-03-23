package com.palipay.palipay_backend.finance.dto.response;

import lombok.Builder;

@Builder
public record WalletResponse(
        String message
) {
}
