package com.palipay.palipay_backend.finance.service;

import com.palipay.palipay_backend.finance.domain.WalletPali;
import com.palipay.palipay_backend.finance.dto.FinanceCommonDto;
import com.palipay.palipay_backend.finance.dto.request.FinanceTransferRequest;
import com.palipay.palipay_backend.finance.repository.WalletPaliRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;

@Service
@RequiredArgsConstructor
public class TransferValidationCommonService {
    private final WalletPaliRepository walletPaliRepository;

    //근데 외부 api에서 확인해야 하지 않나?
    //외부 은행에 정보 확인하고 사업자 정보 받아야 함

    //FIXME exception 구체화
    public WalletPali validate(
            Long userId,
            WalletPali walletPaliReq,
            FinanceCommonDto req)
    {

        //TODO wallet not found exception
        WalletPali walletPali = walletPaliRepository.findByUserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("no wallet"));

        //wallet의 주인이 userId가 아닐 경우 예외
        if(!walletPali.isOwnedBy(userId)){
            throw new IllegalArgumentException("wallet의 주인이 userId가 아닐 경우 예외");
        }

        //source amount 음수 일 경우 예외
        if(req.sourceAmount().compareTo(BigDecimal.ZERO) <= 0){
            throw new IllegalArgumentException("amount 음수 일 경우 예외");
        }

        //송금 시 부족 예외
        if(walletPali.getAmount().compareTo(req.sourceAmount()) < 0){
            throw new IllegalArgumentException("송금 시 부족 예외");
        }

        //TODO 현재 내 계좌 잔액이 음수일 경우 에외???

        return walletPali;
    }
}
