package com.palipay.palipay_backend.finance.service;

import com.palipay.palipay_backend.finance.domain.WalletPali;
import com.palipay.palipay_backend.finance.repository.WalletPaliRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;

@Service
@RequiredArgsConstructor
public class WalletDebitService {
    private final WalletPaliRepository walletPaliRepository;

    public WalletPali debit(Long walletId, BigDecimal amount){
        //TODO 지갑 미존재 예외처리 추가
        WalletPali walletPali = walletPaliRepository.findById(walletId)
                .orElseThrow(() -> new IllegalArgumentException("지갑 미존재 예외처리 추가"));

        //TODO 금액 예외처리 추가
        if(walletPali.getAmount().compareTo(amount) < 0){
            throw new IllegalArgumentException("금액 예외처리 추가");
        }

        walletPali.debit(amount);
        return walletPali;
    }

    public WalletPali getWalletPali(Long walletId){
        return walletPaliRepository.findById(walletId)
                .orElseThrow(() -> new IllegalArgumentException("지갑 미존재 예외처리 추가"));
    }

    public WalletPali getWalletPaliUserId(Long userId){
        return walletPaliRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("지갑 미존재 예외처리 추가"));
    }
}
