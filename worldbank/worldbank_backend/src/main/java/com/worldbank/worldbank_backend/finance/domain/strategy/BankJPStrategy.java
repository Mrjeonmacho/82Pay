package com.worldbank.worldbank_backend.finance.domain.strategy;

import com.worldbank.worldbank_backend.finance.domain.dto.TransferRequestDto;
import com.worldbank.worldbank_backend.finance.domain.entity.jp.AccountHistoryJP;
import com.worldbank.worldbank_backend.finance.domain.entity.jp.BankJP;
import com.worldbank.worldbank_backend.finance.domain.repository.jp.AccountHistoryJPRepository;
import com.worldbank.worldbank_backend.finance.domain.repository.jp.BankJPRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class BankJPStrategy implements BankStrategy {

    private final BankJPRepository bankRepository;
    private final AccountHistoryJPRepository historyRepository;

    @Override
    public String getBankCode() {
        return "JP";
    }

    @Override
    public void withdraw(TransferRequestDto request) {

        BankJP account = bankRepository
                .findByAccountNumber(request.getSenderAccountNumber())
                .orElseThrow(() -> new RuntimeException("계좌 없음"));

        account.withdraw(request.getSenderAmount());

        AccountHistoryJP history = AccountHistoryJP.builder()
                .bankId(account.getBankId())
                .userId(account.getUserId())
                .category(AccountHistoryJP.Category.OUTPUT)
                .amount(request.getSenderAmount())
                .otherAccountNumber(request.getTargetAccountNumber())
                .otherAccountName(request.getTargetAccountName())
                .otherBankCode(request.getTargetBankcode())
                .build();

        historyRepository.save(history);
    }

    @Override
    public void deposit(TransferRequestDto request) {

        BankJP account = bankRepository
                .findByAccountNumber(request.getTargetAccountNumber())
                .orElseThrow(() -> new RuntimeException("계좌 없음"));

        account.deposit(request.getTargetAmount());

        AccountHistoryJP history = AccountHistoryJP.builder()
                .bankId(account.getBankId())
                .userId(account.getUserId())
                .category(AccountHistoryJP.Category.INPUT)
                .amount(request.getTargetAmount())
                .otherAccountNumber(request.getSenderAccountNumber())
                .otherAccountName(request.getSenderAccountName())
                .otherBankCode(request.getSenderBankcode())
                .build();

        historyRepository.save(history);
    }
}