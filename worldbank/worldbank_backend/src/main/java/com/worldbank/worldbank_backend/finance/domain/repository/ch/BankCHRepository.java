package com.worldbank.worldbank_backend.finance.domain.repository.ch;

import com.worldbank.worldbank_backend.finance.domain.entity.ch.BankCH;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface BankCHRepository
        extends JpaRepository<BankCH, Long> {

    @Lock(LockModeType.PESSIMISTIC_WRITE) //비관적 락
    Optional<BankCH> findByAccountNumber(String accountNumber);

    Optional<BankCH> findByUserId(Long userId);

    @Query("SELECT b FROM BankCH b WHERE b.accountNumber = :accountNumber")
    Optional<BankCH> findByAccountNumberNoLock(@Param("accountNumber") String accountNumber);
}
