package com.worldbank.worldbank_backend.finance.domain.repository;

import com.worldbank.worldbank_backend.finance.domain.entity.AccountHistoryJP;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AccountHistoryJPRepository
        extends JpaRepository<AccountHistoryJP, Long> {
}
