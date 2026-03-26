package com.worldbank.worldbank_backend.finance.domain.dto.Info;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;

@Getter
@Builder
@AllArgsConstructor
public class InfoResponseDto {
    BigDecimal amount;
    String currency;
    String bankName;
    String userName;
    String accountNumber;
}
