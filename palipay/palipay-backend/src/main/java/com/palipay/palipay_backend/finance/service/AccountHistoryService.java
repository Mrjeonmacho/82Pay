package com.palipay.palipay_backend.finance.service;

import com.palipay.palipay_backend.finance.domain.AccountHistory;
import com.palipay.palipay_backend.finance.domain.TransactionCategory;
import com.palipay.palipay_backend.finance.domain.WalletPali;
import com.palipay.palipay_backend.finance.repository.AccountHistoryRepository;
import com.palipay.palipay_backend.global.bank.BankCode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;

@Service
@RequiredArgsConstructor
public class AccountHistoryService {
    private final AccountHistoryRepository accountHistoryRepository;

    //FIXME 환율 정보 없이 저장하는 방식 수정
    public AccountHistory createHistory(
            Long userId,
            WalletPali wallet,
            TransactionCategory transactionCategory,
            String accountNumber,
            String accountName,
            String description,
            BankCode bankCode,
            BigDecimal amount,
            Long workplaceId,
            BigDecimal exchangeRate
    ){
        AccountHistory accountHistory = AccountHistory.createAccountHistory(
                userId,
                wallet,
                workplaceId,
                transactionCategory,
                amount,
                description,
                accountNumber,
                accountName,
                bankCode.name(),
                exchangeRate
        );
        return accountHistoryRepository.save(accountHistory);
    }
}
