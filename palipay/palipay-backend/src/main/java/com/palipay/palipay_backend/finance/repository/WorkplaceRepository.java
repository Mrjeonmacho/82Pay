package com.palipay.palipay_backend.finance.repository;

import com.palipay.palipay_backend.finance.domain.Workplace;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface WorkplaceRepository extends JpaRepository<Workplace, Long> {

    Optional<Workplace> findByBusinessNumber(String businessNumber);

    boolean existsByBusinessNumber(String businessNumber);

    Optional<Workplace> findByCompanyName(String companyName);
}