package com.worldbank.worldbank_backend.finance.domain.dto.Check;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Getter
@Builder
@AllArgsConstructor
public class CheckResponseDto {
    String message;
    BigDecimal amount;
    String currency;
    Boolean check;
}
