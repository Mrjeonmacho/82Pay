package com.palipay.palipay_backend.finance.service;

import com.palipay.palipay_backend.finance.domain.WalletPali;
import com.palipay.palipay_backend.finance.repository.WalletPaliRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class WalletService {
    private final WalletPaliRepository walletPaliRepository;

    @Transactional
    public WalletPali debit(Long walletId, BigDecimal amount) {
        validateAmount(amount);

        //TODO 지갑 미존재 예외처리 추가
        WalletPali walletPali = walletPaliRepository.findById(walletId)
                .orElseThrow(() -> new IllegalArgumentException("지갑이 존재하지 않습니다. walletId=" + walletId));

        if (walletPali.getAmount().compareTo(amount) < 0) {
            throw new IllegalArgumentException("잔액이 부족합니다.");
        }

        walletPali.debit(amount);
        return walletPali;
    }

    @Transactional
    public WalletPali credit(Long walletId, BigDecimal amount) {
        validateAmount(amount);

        //TODO 지갑 미존재 예외처리 추가
        WalletPali walletPali = walletPaliRepository.findById(walletId)
                .orElseThrow(() -> new IllegalArgumentException("지갑이 존재하지 않습니다. walletId=" + walletId));

        walletPali.credit(amount);
        return walletPali;
    }

    @Transactional
    public void initCreateWalletPali(Long userId){
        WalletPali initWalletPali = WalletPali
                .builder()
                .userId(userId)
                .build();

        walletPaliRepository.save(initWalletPali);
    }

    public WalletPali getWalletPali(Long walletId){
        return walletPaliRepository.findById(walletId)
                .orElseThrow(() -> new IllegalArgumentException("지갑 미존재 예외처리 추가"));
    }

    public WalletPali getWalletPaliByUserId(Long userId){
        return walletPaliRepository.findByUserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("지갑 미존재 예외처리 추가"));
    }

    private void validateAmount(BigDecimal amount) {
        //TODO 금액 예외처리 추가
        if (amount == null) {
            throw new IllegalArgumentException("금액은 null일 수 없습니다.");
        }

        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("금액은 0보다 커야 합니다.");
        }
    }
}
