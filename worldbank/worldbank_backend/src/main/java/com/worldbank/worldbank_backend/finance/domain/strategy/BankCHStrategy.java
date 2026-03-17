package com.worldbank.worldbank_backend.finance.domain.strategy;

import com.worldbank.worldbank_backend.finance.domain.dto.Transfer.TransferRequestDto;
import com.worldbank.worldbank_backend.finance.domain.entity.ch.AccountHistoryCH;
import com.worldbank.worldbank_backend.finance.domain.entity.ch.BankCH;
import com.worldbank.worldbank_backend.finance.domain.repository.ch.AccountHistoryCHRepository;
import com.worldbank.worldbank_backend.finance.domain.repository.ch.BankCHRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class BankCHStrategy implements BankStrategy {

    private final BankCHRepository bankRepository;
    private final AccountHistoryCHRepository historyRepository;

    @Override
    public String getBankCode() {
        return "CNY";
    }

    @Override
    public void withdraw(TransferRequestDto request) {
        BankCH account = bankRepository
                .findByAccountNumber(request.getSenderAccountNumber())
                .orElseThrow(() -> new RuntimeException("중국 은행 계좌 없음"));

        account.withdraw(request.getSenderAmount());

        AccountHistoryCH history = AccountHistoryCH.builder()
                .bankId(account.getBankId())
                .userId(account.getUserId())
                .category(AccountHistoryCH.Category.OUTPUT)
                .amount(request.getSenderAmount())
                .otherAccountNumber(request.getTargetAccountNumber())
                .otherAccountName(request.getTargetAccountName())
                .otherBankCode(request.getTargetBankcode())
                .build();

        historyRepository.save(history);
    }

    @Override
    public void deposit(TransferRequestDto request) {
        BankCH account = bankRepository
                .findByAccountNumber(request.getTargetAccountNumber())
                .orElseThrow(() -> new RuntimeException("중국 은행 계좌 없음"));

        account.deposit(request.getTargetAmount());

        AccountHistoryCH history = AccountHistoryCH.builder()
                .bankId(account.getBankId())
                .userId(account.getUserId())
                .category(AccountHistoryCH.Category.INPUT)
                .amount(request.getTargetAmount())
                .otherAccountNumber(request.getSenderAccountNumber())
                .otherAccountName(request.getSenderAccountName())
                .otherBankCode(request.getSenderBankcode())
                .build();

        historyRepository.save(history);
    }
}
