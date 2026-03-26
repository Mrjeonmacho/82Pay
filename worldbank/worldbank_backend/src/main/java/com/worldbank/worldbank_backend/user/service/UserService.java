package com.worldbank.worldbank_backend.user.service;

import java.util.List;
import java.util.Optional;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.worldbank.worldbank_backend.global.jwt.JwtProvider;
import com.worldbank.worldbank_backend.global.redis.RedisRepository;
import com.worldbank.worldbank_backend.global.redis.RefreshToken;
import com.worldbank.worldbank_backend.user.dto.request.LoginRequest;
import com.worldbank.worldbank_backend.user.dto.request.SignupRequest;
import com.worldbank.worldbank_backend.user.dto.response.LoginResponse;
import com.worldbank.worldbank_backend.user.dto.response.TokenResponse;
import com.worldbank.worldbank_backend.user.entity.BaseUser;
import com.worldbank.worldbank_backend.user.strategy.UserStrategy;
import com.worldbank.worldbank_backend.user.strategy.UserStrategyFactory;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserStrategyFactory strategyFactory;
    private final PasswordEncoder passwordEncoder;
    private final List<UserStrategy> strategies;
    private final JwtProvider jwtTokenProvider;
    private final RedisRepository redisRepository;

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
        return strategies.parallelStream()
                .anyMatch(strategy -> strategy.existsByEmail(email));
    }

    @Transactional(readOnly = true)
    public TokenResponse login(LoginRequest request) {
        UserWithCountry foundUser = strategies.parallelStream()
                .map(strategy -> strategy.findByEmail(request.email())
                        .map(user -> new UserWithCountry(user, strategy.getCountryCode())))
                .flatMap(Optional::stream)
                .findFirst()
                .orElseThrow(() -> new RuntimeException("이메일 또는 비밀번호가 틀렸습니다."));

        if (!passwordEncoder.matches(request.password(), foundUser.user().getPassword())) {
            throw new RuntimeException("이메일 또는 비밀번호가 틀렸습니다.");
        }

        String at = jwtTokenProvider.createAccessToken(foundUser.user().getUserId(), foundUser.countryCode());
        String rt = jwtTokenProvider.createRefreshToken(foundUser.user().getUserId());

        // 2. Redis Repository에 RT 저장 (KR1 : rt)
        redisRepository.save(new RefreshToken(foundUser.countryCode(), foundUser.user().getUserId(), rt));

        // 3. 컨트롤러가 응답과 쿠키를 구성할 수 있도록 DTO 반환
        return new TokenResponse(foundUser.user().getUserId(), at, rt);
    }

    private record UserWithCountry(BaseUser user, String countryCode) {
    }

}
