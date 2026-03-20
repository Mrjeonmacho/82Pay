package com.worldbank.worldbank_backend.finance.domain.dto.Check;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class CheckRequestDto {
    String targetAccountNumber;
    String targetAccountName;
    String targetBankCode;
    String targetCurrency;
}
