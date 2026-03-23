package com.worldbank.worldbank_backend.user.repository.kr;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.worldbank.worldbank_backend.user.entity.kr.UserBankKR;

public interface UserBankKRRepository extends JpaRepository<UserBankKR, Long> {
    boolean existsByEmail(String email);

    Optional<UserBankKR> findByEmail(String email);
}
