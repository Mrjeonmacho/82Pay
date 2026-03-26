package com.palipay.palipay_backend.user.service;

import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.palipay.palipay_backend.global.redis.RedisService;
import com.palipay.palipay_backend.global.security.JwtProvider;
import com.palipay.palipay_backend.user.domain.RefreshToken;
import com.palipay.palipay_backend.user.domain.UserPali;
import com.palipay.palipay_backend.user.dto.request.LoginRequest;
import com.palipay.palipay_backend.user.dto.request.PasswordCheckRequest;
import com.palipay.palipay_backend.user.dto.request.PasswordUpdateRequest;
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
    private final RedisService redisService;

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

    public void logout(String authHeader) {
        // 1. 토큰 추출 ("Bearer " 제거)
        String accessToken = authHeader.substring(7);

        // 2. JwtProvider에게 정보 획득 (누구인가? 얼마나 남았나?)
        Long userId = jwtProvider.getUserId(accessToken);
        long remainMs = jwtProvider.getExpiration(accessToken);

        // 3. RedisService에게 명령 (RT 삭제 & AT 블랙리스트 등록)
        // Refresh Token 삭제 (다시 로그인하게 만듦)
        refreshTokenRepository.deleteById(userId);

        // Access Token 블랙리스트 등록 (남은 시간만큼만 보관)
        if (remainMs > 0) {
            redisService.setDataExpire(accessToken, "logout", remainMs);
        }
    }

    @Transactional
    public TokenResponse reissue(String refreshToken) {

        // 1. Refresh Token 유효성 검증 (만료 여부 등)
        if (!jwtProvider.validateToken(refreshToken)) {
            throw new UserException("잘못된 Refresh Token 입니다.", HttpStatus.UNAUTHORIZED);
        }

        // 2. 토큰에서 유저 정보(userId) 추출
        Long userId = jwtProvider.getUserId(refreshToken);

        // 3. Redis에서 저장된 Refresh Token 객체 조회
        RefreshToken savedToken = refreshTokenRepository.findById(userId)
                .orElseThrow(() -> new UserException("로그인 정보가 없습니다.", HttpStatus.UNAUTHORIZED));

        // 4. 값 비교
        if (!savedToken.getRefreshToken().equals(refreshToken)) {
            throw new UserException("잘못된 Refresh Token 입니다.", HttpStatus.UNAUTHORIZED);
        }

        // 5. 새로운 토큰 세트 생성 (Access & Refresh)
        TokenResponse newTokenResponse = jwtProvider.generateToken(userId);

        // 6. Redis 업데이트 (RTR)
        savedToken.updateRefreshToken(newTokenResponse.refreshToken());
        refreshTokenRepository.save(savedToken);

        return newTokenResponse;
    }

    @Transactional
    public void updatePassword(Long userId, PasswordUpdateRequest request) {
        UserPali user = userPaliRepository.findById(userId)
                .orElseThrow(() -> new UserException("사용자를 찾을 수 없습니다.", HttpStatus.NOT_FOUND));

        // 1. 현재 비밀번호 검증
        if (!passwordEncoder.matches(request.currentPassword(), user.getPassword())) {
            throw new UserException("현재 비밀번호가 일치하지 않습니다.", HttpStatus.BAD_REQUEST);
        }

        // 2. 새 비밀번호와 확인 비밀번호 일치 여부 검증
        if (!request.newPassword().equals(request.confirmPassword())) {
            throw new UserException("새 비밀번호와 확인 비밀번호가 일치하지 않습니다.", HttpStatus.BAD_REQUEST);
        }

        // 3. 비밀번호 변경
        user.updatePassword(passwordEncoder.encode(request.newPassword()));

        // 4. 보안 강화: 모든 기기에서 로그아웃 (Redis의 Refresh Token 삭제)
        refreshTokenRepository.deleteById(userId);
    }

    @Transactional(readOnly = true)
    public boolean checkCurrentPassword(Long userId, PasswordCheckRequest request) {
        // 1. 유저 조회
        UserPali user = userPaliRepository.findById(userId)
                .orElseThrow(() -> new UserException("사용자를 찾을 수 없습니다.", HttpStatus.NOT_FOUND));

        // 2. 비밀번호 일치 여부 반환 (matches 메서드 활용)
        return passwordEncoder.matches(request.password(), user.getPassword());
    }

    public UserPali findUserByEmail(String email) {
        return userPaliRepository.findByEmail(email)
                .orElseThrow(() -> new UserException("사용자를 찾을 수 없습니다.", HttpStatus.NOT_FOUND));
    }

}
