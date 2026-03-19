package com.palipay.palipay_backend.finance.service;

import com.palipay.palipay_backend.finance.domain.AccountHistory;
import com.palipay.palipay_backend.finance.domain.TransactionCategory;
import com.palipay.palipay_backend.finance.domain.WalletPali;
import com.palipay.palipay_backend.finance.dto.request.FinanceHistoryRequest;
import com.palipay.palipay_backend.finance.dto.response.FinanceHistoryResponse;
import com.palipay.palipay_backend.finance.repository.AccountHistoryRepository;
import com.palipay.palipay_backend.global.bank.BankCode;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

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

    public FinanceHistoryResponse getTransactionHistories(
            Long userId,
            FinanceHistoryRequest request
    ) {
        int page = request.page() == null ? 0 : request.page().intValue();
        int size = request.size() == null ? 20 : request.size().intValue();


        Pageable pageable = PageRequest.of(
                page,
                size,
                Sort.by(Sort.Direction.DESC, "createdAt")
        );

        Page<AccountHistory> historyPage = accountHistoryRepository.findByWalletIdAndCreatedAtBetween(
                request.walletId(),
                request.from(),
                request.to(),
                pageable
        );

        List<FinanceHistoryResponse.FinanceHistoryItem> items = historyPage.getContent()
                .stream()
                .map(this::toItem)
                .toList();

        FinanceHistoryResponse.FinanceHistoryPage pageInfo =
                new FinanceHistoryResponse.FinanceHistoryPage(
                        historyPage.getNumber(),
                        historyPage.getSize(),
                        historyPage.getTotalElements(),
                        historyPage.getTotalPages()
                );

        FinanceHistoryResponse.FinanceHistoryData data =
                new FinanceHistoryResponse.FinanceHistoryData(items, pageInfo);


        return new FinanceHistoryResponse(
                "거래 내역 조회에 성공했습니다.",
                data
        );
    }

    private FinanceHistoryResponse.FinanceHistoryItem toItem(AccountHistory history) {
        return new FinanceHistoryResponse.FinanceHistoryItem(
                history.getHistoryId(),
                history.getCategory().name(),
                history.getAmount(),
                history.getExchangeAfterAmount(),
                history.getExchangeRate(),
                history.getOtherAccountNumber(),
                history.getOtherAccountName(),
                history.getOtherBankCode(),
                history.getWorkplaceId(),
                history.getCreatedAt(),
                history.getDescription()
        );
    }
}
