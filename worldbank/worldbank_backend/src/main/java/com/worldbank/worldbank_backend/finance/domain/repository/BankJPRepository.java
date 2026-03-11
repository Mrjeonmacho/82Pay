package com.worldbank.worldbank_backend.finance.domain.repository;

import com.worldbank.worldbank_backend.finance.domain.entity.BankJP;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface BankJPRepository
        extends JpaRepository<BankJP, Long> {

    Optional<BankJP> findByAccountNumber(String accountNumber);
}
