package com.palipay.palipay_backend.global.palipayinfo;

import com.palipay.palipay_backend.global.bank.BankCode;

public record PalipayAccountInfo (
        String accountNumber,
        String accountName,
        String currency,
        BankCode bankCode
) {
}
