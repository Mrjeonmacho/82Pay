package com.palipay.palipay_backend.finance.dto.request;

import com.palipay.palipay_backend.finance.domain.TransactionCategory;
import jakarta.validation.constraints.Min;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDateTime;
import java.time.OffsetDateTime;

public record FinanceHistoryRequest(
        Long walletId,

        //@DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
        LocalDateTime from,

        //@DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
        LocalDateTime to,


        TransactionCategory category,

        Long workplaceId,

        @Min(value = 0, message = "page는 0 이상이어야 합니다.")
        Long page,

        @Min(value = 1, message = "size는 1 이상이어야 합니다.")
        Long size
) {
}
