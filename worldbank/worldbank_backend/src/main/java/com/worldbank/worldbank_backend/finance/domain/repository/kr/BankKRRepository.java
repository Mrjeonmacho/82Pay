package com.worldbank.worldbank_backend.finance.domain.repository.kr;

import com.worldbank.worldbank_backend.finance.domain.entity.kr.BankKR;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface BankKRRepository
        extends JpaRepository<BankKR, Long> {

    Optional<BankKR> findByAccountNumber(String accountNumber);
}
