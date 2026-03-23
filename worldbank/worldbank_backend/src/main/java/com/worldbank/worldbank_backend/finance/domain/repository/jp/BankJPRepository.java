package com.worldbank.worldbank_backend.finance.domain.repository.jp;

import com.worldbank.worldbank_backend.finance.domain.entity.jp.BankJP;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface BankJPRepository
        extends JpaRepository<BankJP, Long> {

    @Lock(LockModeType.PESSIMISTIC_WRITE) //비관적 락
    Optional<BankJP> findByAccountNumber(String accountNumber);

    Optional<BankJP> findByUserId(Long userId);

    @Query("SELECT b FROM BankJP b WHERE b.accountNumber = :accountNumber")
    Optional<BankJP> findByAccountNumberNoLock(@Param("accountNumber") String accountNumber);
}
