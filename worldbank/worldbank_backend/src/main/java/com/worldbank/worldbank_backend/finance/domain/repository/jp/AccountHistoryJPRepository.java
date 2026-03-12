package com.worldbank.worldbank_backend.finance.domain.repository.jp;

import com.worldbank.worldbank_backend.finance.domain.entity.jp.AccountHistoryJP;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AccountHistoryJPRepository
        extends JpaRepository<AccountHistoryJP, Long> {
}
