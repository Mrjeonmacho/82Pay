package com.palipay.palipay_backend.finance.service;

import com.palipay.palipay_backend.finance.domain.AccountHistory;
import com.palipay.palipay_backend.finance.domain.TransactionCategory;
import com.palipay.palipay_backend.finance.domain.WalletPali;
import com.palipay.palipay_backend.finance.dto.ExternalTransferResultDto;
import com.palipay.palipay_backend.finance.dto.request.FinanceTransferRequest;
import com.palipay.palipay_backend.finance.repository.AccountHistoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AccountHistoryService {
    private final AccountHistoryRepository accountHistoryRepository;

    public AccountHistory createOutputHistory(
            Long userId,
            String idempotencyKey,
            WalletPali wallet,
            FinanceTransferRequest request,
            ExternalTransferResultDto externalTransferResultDto
    ){
        AccountHistory accountHistory = AccountHistory.createAccountHistory(
                userId,
                wallet,
                request.workplaceId(),
                TransactionCategory.OUTPUT,
                request.amount(),
                request.description(),
                request.otherAccountNumber(),
                request.otherAccountName(),
                String.valueOf(request.otherBankCode())
        );
        return accountHistoryRepository.save(accountHistory);
    }
}
