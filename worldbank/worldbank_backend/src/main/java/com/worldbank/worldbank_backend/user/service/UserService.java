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
                long totalStart = System.currentTimeMillis();
                System.out.println("[login] 시작 email=" + request.email());

                long stepStart = System.currentTimeMillis();

                UserWithCountry foundUser = strategies.parallelStream()
                        .map(strategy -> strategy.findByEmail(request.email())
                                .map(user -> new UserWithCountry(user, strategy.getCountryCode())))
                        .flatMap(Optional::stream)
                        .findFirst()
                        .orElseThrow(() -> {
                                long failTime = System.currentTimeMillis();
                                System.out.println("[login] 사용자 조회 실패, 소요(ms)=" + (failTime - totalStart));
                                return new RuntimeException("이메일 또는 비밀번호가 틀렸습니다.");
                        });

                long stepEnd = System.currentTimeMillis();
                System.out.println("[login] 사용자 조회 성공 userId=" + foundUser.user().getUserId()
                        + ", country=" + foundUser.countryCode()
                        + ", 소요(ms)=" + (stepEnd - stepStart));

                stepStart = System.currentTimeMillis();

                if (!passwordEncoder.matches(request.password(), foundUser.user().getPassword())) {
                        long failTime = System.currentTimeMillis();
                        System.out.println("[login] 비밀번호 검증 실패 userId=" + foundUser.user().getUserId()
                                + ", 소요(ms)=" + (failTime - stepStart));
                        throw new RuntimeException("이메일 또는 비밀번호가 틀렸습니다.");
                }

                stepEnd = System.currentTimeMillis();
                System.out.println("[login] 비밀번호 검증 성공 userId=" + foundUser.user().getUserId()
                        + ", 소요(ms)=" + (stepEnd - stepStart));

                stepStart = System.currentTimeMillis();

                String at = jwtTokenProvider.createAccessToken(foundUser.user().getUserId(), foundUser.countryCode());
                String rt = jwtTokenProvider.createRefreshToken(foundUser.user().getUserId());

                stepEnd = System.currentTimeMillis();
                System.out.println("[login] 토큰 생성 성공 userId=" + foundUser.user().getUserId()
                        + ", accessTokenLength=" + at.length()
                        + ", refreshTokenLength=" + rt.length()
                        + ", 소요(ms)=" + (stepEnd - stepStart));

                stepStart = System.currentTimeMillis();

                redisRepository.save(new RefreshToken(foundUser.countryCode(), foundUser.user().getUserId(), rt));

                stepEnd = System.currentTimeMillis();
                System.out.println("[login] Redis 저장 성공 userId=" + foundUser.user().getUserId()
                        + ", 소요(ms)=" + (stepEnd - stepStart));

                long totalEnd = System.currentTimeMillis();
                System.out.println("[login] 전체 성공 userId=" + foundUser.user().getUserId()
                        + ", 전체 소요(ms)=" + (totalEnd - totalStart));

                return new TokenResponse(foundUser.user().getUserId(), at, rt);
        }

        private record UserWithCountry(BaseUser user, String countryCode) {
        }

}
