package com.worldbank.worldbank_backend.user.repository.us;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.worldbank.worldbank_backend.user.entity.us.UserBankUS;

public interface UserBankUSRepository extends JpaRepository<UserBankUS, Long> {
    boolean existsByEmail(String email);

    Optional<UserBankUS> findByEmail(String email);
}
