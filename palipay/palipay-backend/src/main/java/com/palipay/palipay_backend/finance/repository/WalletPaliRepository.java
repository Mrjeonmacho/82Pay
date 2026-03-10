package com.palipay.palipay_backend.finance.repository;

import com.palipay.palipay_backend.finance.domain.WalletPali;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface WalletPaliRepository extends JpaRepository<WalletPali, Long> {

    Optional<WalletPali> findByUserId(Long userId);

    Optional<WalletPali> findByAccountNumber(String accountNumber);

}