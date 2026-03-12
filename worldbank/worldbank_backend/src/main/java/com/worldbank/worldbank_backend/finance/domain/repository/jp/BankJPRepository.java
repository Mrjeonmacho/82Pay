package com.worldbank.worldbank_backend.finance.domain.repository.jp;

import com.worldbank.worldbank_backend.finance.domain.entity.jp.BankJP;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface BankJPRepository
        extends JpaRepository<BankJP, Long> {

    Optional<BankJP> findByAccountNumber(String accountNumber);
}
