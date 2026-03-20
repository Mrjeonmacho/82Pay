package com.worldbank.worldbank_backend.finance.domain.dto.Link;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
@AllArgsConstructor
public class LinkRequestDto {
    String targetAccountNumber;
    String targetAccountPassword;
    String targetCurrency;
}
