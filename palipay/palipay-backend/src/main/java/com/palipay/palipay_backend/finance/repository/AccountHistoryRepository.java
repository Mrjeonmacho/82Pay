package com.palipay.palipay_backend.finance.repository;

import com.palipay.palipay_backend.finance.domain.AccountHistory;
import com.palipay.palipay_backend.finance.domain.TransactionCategory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.util.List;

public interface AccountHistoryRepository extends JpaRepository<AccountHistory, Long> {

    List<AccountHistory> findByWalletId(Long walletId);

    Page<AccountHistory> findByUserId(Long userId, Pageable pageable);

    Page<AccountHistory> findByUserIdAndCreatedAtBetween(
            Long userId,
            LocalDateTime from,
            LocalDateTime to,
            Pageable pageable
    );

    Page<AccountHistory> findByWalletIdAndCreatedAtBetween(
            Long walletId,
            LocalDateTime from,
            LocalDateTime to,
            Pageable pageable
    );

    Page<AccountHistory> findByWalletIdAndCategory(
            Long walletId,
            TransactionCategory category,
            Pageable pageable
    );


    List<AccountHistory> findByWalletIdAndCategory(Long walletId, TransactionCategory category);

}