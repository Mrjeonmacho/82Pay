package com.worldbank.worldbank_backend.user.repository.jp;

import org.springframework.data.jpa.repository.JpaRepository;

import com.worldbank.worldbank_backend.user.entity.jp.UserBankJP;

public interface UserBankJPRepository extends JpaRepository<UserBankJP, Long> {
    boolean existsByEmail(String email);
}
