package com.palipay.palipay_backend.user.service;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.palipay.palipay_backend.global.security.JwtProvider;
import com.palipay.palipay_backend.user.domain.RefreshToken;
import com.palipay.palipay_backend.user.domain.UserPali;
import com.palipay.palipay_backend.user.dto.request.LoginRequest;
import com.palipay.palipay_backend.user.dto.response.TokenResponse;
import com.palipay.palipay_backend.user.exception.UserException;
import com.palipay.palipay_backend.user.infrastructure.redis.RefreshTokenRepository;
import com.palipay.palipay_backend.user.repository.UserPaliRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserAuthService {

    private final UserPaliRepository userPaliRepository;
    private final BCryptPasswordEncoder passwordEncoder;
    private final JwtProvider jwtProvider;
    private final RefreshTokenRepository refreshTokenRepository;

    @Transactional
    public TokenResponse login(LoginRequest request) {
        // 1. 이메일로 유저 찾기
        UserPali user = userPaliRepository.findByEmail(request.email())
                .orElseThrow(() -> new UserException("아이디 혹은 비밀번호를 확인해주세요."));

        // 2. 비밀번호 검증
        if (!passwordEncoder.matches(request.password(), user.getPassword())) {
            throw new UserException("아이디 혹은 비밀번호를 확인해주세요.");
        }
        // 3. 토큰 생성
        TokenResponse tokenResponse = jwtProvider.generateToken(user.getUserId());

        // 4. 리프레시 토큰 저장
        RefreshToken refreshToken = new RefreshToken(user.getUserId(), tokenResponse.refreshToken());
        refreshTokenRepository.save(refreshToken);

        // 5. 토큰 반환
        return tokenResponse;
    }
}
