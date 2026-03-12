package com.worldbank.worldbank_backend.finance.domain.repository.kr;

import com.worldbank.worldbank_backend.finance.domain.entity.kr.AccountHistoryKR;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AccountHistoryKRRepository
        extends JpaRepository<AccountHistoryKR, Long> {
}
