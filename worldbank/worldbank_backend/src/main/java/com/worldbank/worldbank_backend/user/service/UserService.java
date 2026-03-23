package com.worldbank.worldbank_backend.user.service;

import java.util.List;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.worldbank.worldbank_backend.user.dto.request.SignupRequest;
import com.worldbank.worldbank_backend.user.strategy.UserStrategy;
import com.worldbank.worldbank_backend.user.strategy.UserStrategyFactory;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserStrategyFactory strategyFactory;
    private final PasswordEncoder passwordEncoder;
    private final List<UserStrategy> strategies;

    @Transactional
    public void signUp(SignupRequest request) {
        // 1. 공통: 비밀번호 암호화
        String encodedPassword = passwordEncoder.encode(request.getPassword());

        // 2. 국적에 맞는 전략 선택
        UserStrategy strategy = strategyFactory.getStrategy(request.getCountryCode());

        // 3. 전략 실행 (유저저장 + 계좌등록)
        strategy.signup(request, encodedPassword);
    }

    @Transactional(readOnly = true)
    public boolean isEmailDuplicate(String email) {
        return strategies.stream()
                .anyMatch(strategy -> strategy.existsByEmail(email));
    }

}
