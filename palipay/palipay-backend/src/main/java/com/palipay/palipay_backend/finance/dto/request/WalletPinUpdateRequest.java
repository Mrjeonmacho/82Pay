package com.palipay.palipay_backend.finance.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record WalletPinUpdateRequest(
        @NotNull
        Long walletId,

        @NotBlank
        String oldPinNumber,

        @NotBlank
        String newPinNumber
) {
}
