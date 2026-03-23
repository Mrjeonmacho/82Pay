package com.worldbank.worldbank_backend.user.strategy;

import java.time.LocalDateTime;

import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import com.worldbank.worldbank_backend.finance.domain.service.BusinessService;
import com.worldbank.worldbank_backend.user.dto.request.SignupRequest;
import com.worldbank.worldbank_backend.user.entity.UserStatus;
import com.worldbank.worldbank_backend.user.entity.kr.UserBankKR;
import com.worldbank.worldbank_backend.user.repository.kr.UserBankKRRepository;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class KrUserStrategy implements UserStrategy {

    private final UserBankKRRepository userRepository;
    private final BusinessService businessService;

    @Override
    public String getCountryCode() {
        return "KR";
    }

    @Override
    public boolean existsByEmail(String email) {
        return userRepository.existsByEmail(email);
    }

    @Override
    @Transactional
    public void signup(SignupRequest request, String encodedPassword) {
        // 1. 한국 유저 엔티티 생성 및 저장
        UserBankKR user = UserBankKR.builder()
                .email(request.getEmail())
                .password(encodedPassword)
                .build();
        userRepository.save(user);

        // 계좌 등록 로직 추가
    }

}
