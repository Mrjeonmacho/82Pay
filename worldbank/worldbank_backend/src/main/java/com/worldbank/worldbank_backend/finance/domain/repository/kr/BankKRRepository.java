package com.worldbank.worldbank_backend.finance.domain.repository.kr;

import com.worldbank.worldbank_backend.finance.domain.entity.kr.BankKR;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface BankKRRepository
        extends JpaRepository<BankKR, Long> {

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    Optional<BankKR> findByAccountNumber(String accountNumber);

    Optional<BankKR> findByUserId(Long userId);

    @Query("SELECT b FROM BankKR b WHERE b.accountNumber = :accountNumber")
    Optional<BankKR> findByAccountNumberNoLock(@Param("accountNumber") String accountNumber);
}
