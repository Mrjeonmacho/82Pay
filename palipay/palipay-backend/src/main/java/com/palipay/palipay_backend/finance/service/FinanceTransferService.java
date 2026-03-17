package com.palipay.palipay_backend.finance.service;

import com.palipay.palipay_backend.finance.domain.TransactionCategory;
import com.palipay.palipay_backend.finance.domain.WalletPali;
import com.palipay.palipay_backend.finance.dto.FinanceCommonDto;
import com.palipay.palipay_backend.finance.dto.request.FinanceTransferRequest;
import com.palipay.palipay_backend.finance.dto.response.FinanceTransferResponse;
import com.palipay.palipay_backend.global.bank.BankCode;
import com.palipay.palipay_backend.global.palipayinfo.PalipayAccountProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

//모든 거래 서비스 통합 서비스
@Service
@RequiredArgsConstructor
public class FinanceTransferService {
    private final WalletService walletService;
    private final FinanceCommonService financeCommonService;

    private final PalipayAccountProvider palipayAccountProvider;


    public FinanceTransferResponse transfer(
            Long userId,
            String idempotencyKey,
            FinanceTransferRequest request
    ) {
        WalletPali walletPali = walletService.getWalletPali(request.walletId());

        /*
        * FIXME
        *  송금의 경우 source는 kr 뱅크에 palipay 고정계좌이다.
        *
        * */

        String currency = palipayAccountProvider.getPalipayAccountInfo().currency();
        FinanceCommonDto financeCommonDto = new FinanceCommonDto(
                palipayAccountProvider.getPalipayAccountInfo().accountNumber(),
                palipayAccountProvider.getPalipayAccountInfo().accountName(),
                palipayAccountProvider.getPalipayAccountInfo().bankCode(),

                request.amount(),
                currency,

                request.otherAccountNumber(),
                request.otherAccountName(),
                request.otherBankCode(),
                request.amount(),
                currency,

                request.description(),
                TransactionCategory.OUTPUT
        );

        return financeCommonService.transfer(
                userId,
                idempotencyKey,
                walletPali,
                financeCommonDto,
                request.pinNumber(),
                request.workplaceId()
        );
    }
}
