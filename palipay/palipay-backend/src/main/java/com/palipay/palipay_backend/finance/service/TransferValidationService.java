package com.palipay.palipay_backend.finance.service;

import com.palipay.palipay_backend.finance.domain.WalletPali;
import com.palipay.palipay_backend.finance.dto.request.FinanceTransferRequest;
import com.palipay.palipay_backend.finance.repository.WalletPaliRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;

@Service
@RequiredArgsConstructor
public class TransferValidationService {
    private final WalletPaliRepository walletPaliRepository;

    //근데 외부 api에서 확인해야 하지 않나?
    //외부 은행에 정보 확인하고 사업자 정보 받아야 함

    //FIXME exception 구체화
    public WalletPali validate(Long userId, FinanceTransferRequest req) {

        //TODO wallet not found exception
        WalletPali walletPali = walletPaliRepository.findById(req.walletId())
                .orElseThrow(() -> new IllegalArgumentException("no wallet"));

        //TODO wallet의 주인이 userId가 아닐 경우 예외
        if(!walletPali.isOwnedBy(userId)){
            throw new IllegalArgumentException("wallet의 주인이 userId가 아닐 경우 예외");
        }

        //TODO pin unmatch 예외
        if(!walletPali.matchesPin(req.pinNumber())){
            throw new IllegalArgumentException("pin unmatch 예외");
        }

        //TODO amount 음수 일 경우 예외
        if(req.amount().compareTo(BigDecimal.ZERO) <= 0){
            throw new IllegalArgumentException("amount 음수 일 경우 예외");
        }

        //TODO 송금 시 부족 예외
        if(walletPali.getAmount().compareTo(req.amount()) < 0){
            throw new IllegalArgumentException("송금 시 부족 예외");
        }

        //TODO 현재 내 계좌 잔액이 음수일 경우 에외???

        return walletPali;
    }

}
