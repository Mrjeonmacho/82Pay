package com.palipay.palipay_backend.finance.repository;

import com.palipay.palipay_backend.finance.domain.AccountHistory;
import com.palipay.palipay_backend.finance.domain.TransactionCategory;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AccountHistoryRepository extends JpaRepository<AccountHistory, Long> {

    List<AccountHistory> findByWalletId(Long walletId);

    List<AccountHistory> findByUserId(Long userId);

    List<AccountHistory> findByWalletIdAndCategory(Long walletId, TransactionCategory category);

}