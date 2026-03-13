package com.worldbank.worldbank_backend.finance.domain.strategy;

import com.worldbank.worldbank_backend.finance.domain.dto.TransferRequestDto;
import com.worldbank.worldbank_backend.finance.domain.entity.us.AccountHistoryUS;
import com.worldbank.worldbank_backend.finance.domain.entity.us.BankUS;
import com.worldbank.worldbank_backend.finance.domain.repository.us.AccountHistoryUSRepository;
import com.worldbank.worldbank_backend.finance.domain.repository.us.BankUSRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class BankUSStrategy implements BankStrategy {

    private final BankUSRepository bankRepository;
    private final AccountHistoryUSRepository historyRepository;

    @Override
    public String getBankCode() {
        return "US";
    }

    @Override
    public void withdraw(TransferRequestDto request) {
        BankUS account = bankRepository
                .findByAccountNumber(request.getSenderAccountNumber())
                .orElseThrow(() -> new RuntimeException("미국 은행 계좌 없음"));

        account.withdraw(request.getSenderAmount());

        AccountHistoryUS history = AccountHistoryUS.builder()
                .bankId(account.getBankId())
                .userId(account.getUserId())
                .category(AccountHistoryUS.Category.OUTPUT)
                .amount(request.getSenderAmount())
                .otherAccountNumber(request.getTargetAccountNumber())
                .otherAccountName(request.getTargetAccountName())
                .otherBankCode(request.getTargetBankcode())
                .build();

        historyRepository.save(history);
    }

    @Override
    public void deposit(TransferRequestDto request) {
        BankUS account = bankRepository
                .findByAccountNumber(request.getTargetAccountNumber())
                .orElseThrow(() -> new RuntimeException("미국 은행 계좌 없음"));

        account.deposit(request.getTargetAmount());

        AccountHistoryUS history = AccountHistoryUS.builder()
                .bankId(account.getBankId())
                .userId(account.getUserId())
                .category(AccountHistoryUS.Category.INPUT)
                .amount(request.getTargetAmount())
                .otherAccountNumber(request.getSenderAccountNumber())
                .otherAccountName(request.getSenderAccountName())
                .otherBankCode(request.getSenderBankcode())
                .build();

        historyRepository.save(history);
    }
}
