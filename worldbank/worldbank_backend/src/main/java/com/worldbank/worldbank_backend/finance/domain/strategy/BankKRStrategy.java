package com.worldbank.worldbank_backend.finance.domain.strategy;

import com.worldbank.worldbank_backend.finance.domain.dto.Transfer.TransferRequestDto;
import com.worldbank.worldbank_backend.finance.domain.entity.kr.AccountHistoryKR;
import com.worldbank.worldbank_backend.finance.domain.entity.kr.BankKR;
import com.worldbank.worldbank_backend.finance.domain.repository.kr.AccountHistoryKRRepository;
import com.worldbank.worldbank_backend.finance.domain.repository.kr.BankKRRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class BankKRStrategy implements BankStrategy{

    private final BankKRRepository bankRepository;
    private final AccountHistoryKRRepository historyRepository;

    @Override
    public String getBankCurrency() {
        return "KRW";
    }

    @Override
    public void withdraw(TransferRequestDto request) {
        BankKR account = bankRepository
                .findByAccountNumber(request.getSenderAccountNumber())
                .orElseThrow(() -> new RuntimeException("계좌 없음"));

        account.withdraw(request.getSenderAmount());

        AccountHistoryKR history = AccountHistoryKR.builder()
                .bankId(account.getBankId())
                .userId(account.getUserId())
                .category(AccountHistoryKR.Category.OUTPUT)
                .amount(request.getSenderAmount())
                .otherAccountNumber(request.getTargetAccountNumber())
                .otherAccountName(request.getTargetAccountName())
                .otherBankCode(request.getTargetBankcode())
                .build();
        historyRepository.save(history);
    }

    @Override
    public void deposit(TransferRequestDto request) {
        BankKR account = bankRepository
                .findByAccountNumber(request.getTargetAccountNumber())
                .orElseThrow(() -> new RuntimeException("계좌 없음"));

        account.deposit(request.getTargetAmount());

        AccountHistoryKR history = AccountHistoryKR.builder()
                .bankId(account.getBankId())
                .userId(account.getUserId())
                .category(AccountHistoryKR.Category.INPUT)
                .amount(request.getTargetAmount())
                .otherAccountNumber(request.getSenderAccountNumber())
                .otherAccountName(request.getSenderAccountName())
                .otherBankCode(request.getSenderBankcode())
                .build();
        historyRepository.save(history);
    }
}
