package com.worldbank.worldbank_backend.finance.domain.repository.ch;

import com.worldbank.worldbank_backend.finance.domain.entity.ch.AccountHistoryCH;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AccountHistoryCHRepository
        extends JpaRepository<AccountHistoryCH, Long> {
}
