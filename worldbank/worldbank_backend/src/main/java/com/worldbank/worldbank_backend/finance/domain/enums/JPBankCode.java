package com.worldbank.worldbank_backend.finance.domain.enums;

import lombok.Getter;

@Getter
public enum JPBankCode {

    JPPSJPJ1("Japan Post Bank"),
    BOTKJPJT("MUFG Bank"),
    SMBCJPJT("Sumitomo Mitsui Banking Corporation"),
    MHCBJPJT("Mizuho Bank"),
    DIWAJPJT("Resona Bank");

    private final String bankName;

    JPBankCode(String bankName) {
        this.bankName = bankName;
    }
}