package com.worldbank.worldbank_backend.user.strategy;

import java.time.LocalDateTime;
import java.util.Optional;

import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import com.worldbank.worldbank_backend.finance.domain.service.BusinessService;
import com.worldbank.worldbank_backend.user.dto.request.SignupRequest;
import com.worldbank.worldbank_backend.user.entity.UserStatus;
import com.worldbank.worldbank_backend.user.entity.ch.UserBankCH;
import com.worldbank.worldbank_backend.user.repository.ch.UserBankCHRepository;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class CHUserStrategy implements UserStrategy {

    private final UserBankCHRepository userRepository;
    private final BusinessService businessService;

    @Override
    public String getCountryCode() {
        return "CH";
    }

    @Override
    public boolean existsByEmail(String email) {
        return userRepository.existsByEmail(email);
    }

    @Override
    public Optional<UserBankCH> findByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    @Override
    @Transactional
    public void signup(SignupRequest request, String encodedPassword) {
        // 1. 중국 유저 엔티티 생성 및 저장
        UserBankCH user = UserBankCH.builder()
                .email(request.getEmail())
                .password(encodedPassword)
                .currency("CNY")
                .build();
        userRepository.save(user);

        // 계좌 등록 로직 추가
    }

}
