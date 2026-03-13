package com.worldbank.worldbank_backend.finance.domain.repository.ch;

import com.worldbank.worldbank_backend.finance.domain.entity.ch.BankCH;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;

import java.util.Optional;

public interface BankCHRepository
        extends JpaRepository<BankCH, Long> {

    @Lock(LockModeType.PESSIMISTIC_WRITE) //비관적 락
    Optional<BankCH> findByAccountNumber(String accountNumber);
}
