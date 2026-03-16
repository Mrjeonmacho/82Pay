package com.worldbank.worldbank_backend.finance.domain.dto.Business;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class BusinessResponseDto {

    private String message;
    private BusinessData data;

    @Getter
    @Builder
    @AllArgsConstructor
    @NoArgsConstructor
    public static class BusinessData {
        private String companyName;
        private String businessPerson;
    }
}
