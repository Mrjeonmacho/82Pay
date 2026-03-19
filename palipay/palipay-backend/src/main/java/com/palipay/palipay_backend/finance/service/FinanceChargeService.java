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
public class FinanceChargeService {
    private final WalletService walletService;
    private final FinanceCommonService financeCommonService;

    //FIXME 전역 provider로 정보 받고 있는 중
    private final PalipayAccountProvider palipayAccountProvider;

    public FinanceAdjustmentResponse charge(
            Long userId,
            String idempotencyKey,
            FinanceAdjustmentRequest request
    ){
        /*
        * 충전의 경우
        *  source가 외국 계좌 - source currency는 wallet 내부에 있음
        *  target은 palipay 계좌 - KRW
        * */
        WalletPali walletPali = walletService.getWalletPali(request.walletId());

        //FIXME wallet에 bank는 string이라 직접 변환 필요
        //FIXME bankCode
        FinanceCommonDto financeCommonDto = new FinanceCommonDto(
                walletPali.getAccountNumber(),
                walletPali.getAccountUsername(),
                BankCode.valueOf(walletPali.getBankCode()),
                request.amount(),
                walletPali.getMoneyCode(),

                palipayAccountProvider.getPalipayAccountInfo().accountNumber(),
                palipayAccountProvider.getPalipayAccountInfo().accountName(),
                palipayAccountProvider.getPalipayAccountInfo().bankCode(),

                request.convertedAmount(),
                palipayAccountProvider.getPalipayAccountInfo().currency(),
                null,
                TransactionCategory.INPUT
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
        /*적용 결과 값으로 적용 환율 반환*/
        BigDecimal exchangeRate = request.convertedAmount().divide(request.amount(), 6, RoundingMode.HALF_UP);

        return FinanceAdjustmentResponse.success(
                commonResponse.data().transactionId(),
                request.convertedAmount(),
                exchangeRate,
                commonResponse.data().currentBalance(),
                commonResponse.data().createdAt()
        );
    }
}
