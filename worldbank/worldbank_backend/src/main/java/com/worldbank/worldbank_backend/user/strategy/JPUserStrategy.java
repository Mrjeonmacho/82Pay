package com.worldbank.worldbank_backend.user.strategy;

import java.time.LocalDateTime;

import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import com.worldbank.worldbank_backend.finance.domain.service.BusinessService;
import com.worldbank.worldbank_backend.user.dto.request.SignupRequest;
import com.worldbank.worldbank_backend.user.entity.UserStatus;
import com.worldbank.worldbank_backend.user.entity.jp.UserBankJP;
import com.worldbank.worldbank_backend.user.repository.jp.UserBankJPRepository;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class JPUserStrategy implements UserStrategy {

    private final UserBankJPRepository userRepository;
    private final BusinessService businessService;

    @Override
    public String getCountryCode() {
        return "JP";
    }

    @Override
    public boolean existsByEmail(String email) {
        return userRepository.existsByEmail(email);
    }

    @Override
    @Transactional
    public void signup(SignupRequest request, String encodedPassword) {
        // 1. 일본 유저 엔티티 생성 및 저장
        UserBankJP user = UserBankJP.builder()
                .email(request.getEmail())
                .password(encodedPassword)
                .build();
        userRepository.save(user);

        // 계좌 등록 로직 추가

    }

}
