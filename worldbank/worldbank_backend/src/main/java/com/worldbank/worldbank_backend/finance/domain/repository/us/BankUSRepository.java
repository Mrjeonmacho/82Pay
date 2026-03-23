package com.worldbank.worldbank_backend.finance.domain.repository.us;

import com.worldbank.worldbank_backend.finance.domain.entity.us.BankUS;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface BankUSRepository
        extends JpaRepository<BankUS, Long> {

    @Lock(LockModeType.PESSIMISTIC_WRITE) //비관적 락
    Optional<BankUS> findByAccountNumber(String accountNumber);

    Optional<BankUS> findByUserId(Long userId);

    @Query("SELECT b FROM BankUS b WHERE b.accountNumber = :accountNumber")
    Optional<BankUS> findByAccountNumberNoLock(@Param("accountNumber") String accountNumber);
}
