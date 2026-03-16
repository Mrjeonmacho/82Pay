package com.palipay.palipay_backend.finance.service;

import com.palipay.palipay_backend.finance.domain.TransactionCategory;
import com.palipay.palipay_backend.finance.domain.WalletPali;
import com.palipay.palipay_backend.finance.dto.FinanceCommonDto;
import com.palipay.palipay_backend.finance.dto.request.FinanceAdjustmentRequest;
import com.palipay.palipay_backend.finance.dto.response.FinanceAdjustmentResponse;
import com.palipay.palipay_backend.finance.dto.response.FinanceTransferResponse;
import com.palipay.palipay_backend.global.bank.BankCode;
import com.palipay.palipay_backend.global.palipayinfo.PalipayAccountProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;

@Service
@RequiredArgsConstructor
public class FinanceRefundService {
    private final WalletService walletService;
    private final FinanceCommonService financeCommonService;

    //FIXME 전역 provider로 정보 받고 있는 중
    private final PalipayAccountProvider palipayAccountProvider;

    public FinanceAdjustmentResponse refund(
            Long userId,
            String idempotencyKey,
            FinanceAdjustmentRequest request
    ){
        /*
        * TODO 환불의 경우
        *  source가 palipay - KRW
        *  target이 외국 계좌
        * */
        WalletPali walletPali = walletService.getWalletPali(request.walletId());


        //FIXME wallet에 bank는 string이라 직접 변환 필요
        //FIXME bankCode
        FinanceCommonDto financeCommonDto = new FinanceCommonDto(
                palipayAccountProvider.getPalipayAccountInfo().accountNumber(),
                palipayAccountProvider.getPalipayAccountInfo().accountName(),
                palipayAccountProvider.getPalipayAccountInfo().bankCode(),
                request.convertedAmount(),
                palipayAccountProvider.getPalipayAccountInfo().currency(),

                walletPali.getAccountNumber(),
                walletPali.getAccountUsername(),
                BankCode.valueOf(walletPali.getBankCode()),
                request.amount(),
                walletPali.getMoneyCode(),

                null,
                TransactionCategory.OUTPUT
        );


        FinanceTransferResponse commonResponse = financeCommonService.transfer(
                userId,
                idempotencyKey,
                walletPali,
                financeCommonDto,
                request.pinNumber(),
                null
        );

        //FIXME exchangeRate 직접 계산 중
        BigDecimal exchangeRate = request.amount().divide(request.convertedAmount(), 6, RoundingMode.HALF_UP);

        //FIXME null 대체
        return FinanceAdjustmentResponse.success(
                commonResponse.data().transactionId(),
                request.convertedAmount(),
                exchangeRate,
                commonResponse.data().currentBalance(),
                commonResponse.data().createdAt()
        );
    }
}
