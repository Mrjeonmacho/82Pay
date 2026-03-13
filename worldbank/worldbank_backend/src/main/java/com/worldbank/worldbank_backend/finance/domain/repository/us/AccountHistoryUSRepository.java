package com.worldbank.worldbank_backend.finance.domain.repository.us;

import com.worldbank.worldbank_backend.finance.domain.entity.us.AccountHistoryUS;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AccountHistoryUSRepository
        extends JpaRepository<AccountHistoryUS, Long> {
}
