package com.worldbank.worldbank_backend.user.strategy;

import java.time.LocalDateTime;

import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import com.worldbank.worldbank_backend.finance.domain.service.BusinessService;
import com.worldbank.worldbank_backend.user.dto.request.SignupRequest;
import com.worldbank.worldbank_backend.user.entity.UserStatus;
import com.worldbank.worldbank_backend.user.entity.us.UserBankUS;
import com.worldbank.worldbank_backend.user.repository.us.UserBankUSRepository;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class USUserStrategy implements UserStrategy {

    private final UserBankUSRepository userRepository;
    private final BusinessService businessService;

    @Override
    public String getCountryCode() {
        return "US";
    }

    @Override
    public boolean existsByEmail(String email) {
        return userRepository.existsByEmail(email);
    }

    @Override
    @Transactional
    public void signup(SignupRequest request, String encodedPassword) {
        // 1. 미국 유저 엔티티 생성 및 저장
        UserBankUS user = UserBankUS.builder()
                .email(request.getEmail())
                .password(encodedPassword)
                .build();
        userRepository.save(user);

        // 계좌 등록 로직 추가
    }

}
