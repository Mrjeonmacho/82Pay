package com.worldbank.worldbank_backend.finance.domain.repository.kr;

import com.worldbank.worldbank_backend.finance.domain.entity.kr.Business;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface BusinessRepository extends JpaRepository<Business, Long> {
    Optional<Business> findByAccount_AccountNumber(String accountNumber);
}
