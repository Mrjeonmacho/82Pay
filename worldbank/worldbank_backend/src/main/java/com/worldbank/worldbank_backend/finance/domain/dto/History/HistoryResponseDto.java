package com.worldbank.worldbank_backend.finance.domain.dto.History;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class HistoryResponseDto {
    private Long historyId;
    private String category; // INPUT, OUTPUT
    private BigDecimal amount;
    private String otherAccountNumber;
    private String otherAccountName;
    private String otherBankCode;
    private LocalDateTime createdAt;
}
