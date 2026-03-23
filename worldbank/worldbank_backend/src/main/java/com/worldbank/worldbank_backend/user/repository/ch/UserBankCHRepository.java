package com.worldbank.worldbank_backend.user.repository.ch;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.worldbank.worldbank_backend.user.entity.ch.UserBankCH;

public interface UserBankCHRepository extends JpaRepository<UserBankCH, Long> {
    boolean existsByEmail(String email);

    Optional<UserBankCH> findByEmail(String email);
}
