package com.palipay.palipay_backend.finance.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Builder;

@Builder
public record WalletPinRequest(
        @NotNull(message = "walletId는 필수입니다.")
        Long walletId,

        @NotBlank(message = "pinNumber는 필수입니다.")
        String pinNumber
) {
}
