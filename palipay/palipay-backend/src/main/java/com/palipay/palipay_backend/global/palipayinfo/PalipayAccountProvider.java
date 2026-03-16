package com.palipay.palipay_backend.global.palipayinfo;

import com.palipay.palipay_backend.global.bank.BankCode;
import org.springframework.stereotype.Component;

@Component
public class PalipayAccountProvider {
    public PalipayAccountInfo getPalipayAccountInfo() {
        return new PalipayAccountInfo(
                "123-456-7890",
                "PaliPay",
                "KRW",
                BankCode.ABOCCNBJ
        );
    }
}
