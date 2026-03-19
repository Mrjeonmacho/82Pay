package com.palipay.palipay_backend.user.service;

import java.security.SecureRandom;
import java.time.LocalDateTime;

import com.palipay.palipay_backend.user.domain.UserStatus;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.palipay.palipay_backend.global.redis.RedisService;
import com.palipay.palipay_backend.user.domain.UserPali;
import com.palipay.palipay_backend.user.dto.request.JoinRequest;
import com.palipay.palipay_backend.user.exception.UserException;
import com.palipay.palipay_backend.user.infrastructure.mail.EmailSender;
import com.palipay.palipay_backend.user.repository.UserPaliRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UserJoinService {
    private final UserPaliRepository userPaliRepository;
    private final RedisService redisService;
    private final EmailSender emailSender;
    private final BCryptPasswordEncoder passwordEncoder;

    // 1. 이메일 중복 체크
    @Transactional(readOnly = true)
    public boolean isEmailAvailable(String type, String value) {
        return switch (type) {
            case "email" -> !userPaliRepository.existsByEmail(value);
            default -> throw new UserException("지원하지 않는 인증 타입입니다.", HttpStatus.BAD_REQUEST);
        };
    }

    // 2. 인증번호 발송
    public void sendAuthCode(String email) {
        // 6자리 난수 생성
        String authCode = generateAuthCode();

        // redis에 저장 (만료시간 3분)
        redisService.setDataExpire("AUTH_CODE:" + email, authCode, 180000);

        // 이메일 발송
        emailSender.sendEmail(email, authCode);
    }

    // 3. 인증번호 확인
    public boolean verifyCode(String email, String userInputCode) {
        // redis 에서 해당 email로 저장된 code를 가져옴
        String savedCode = redisService.getData("AUTH_CODE:" + email);

        // 저장된 코드가 없거나(만료), 입력한 코드와 일치하지 않으면 false
        if (savedCode == null) {
            throw new UserException("인증 시간이 만료되었습니다.", HttpStatus.BAD_REQUEST);
        }

        if (!savedCode.equals(userInputCode)) {
            throw new UserException("인증번호가 일치하지 않습니다.", HttpStatus.BAD_REQUEST);
        }

        // 인증 성공 시 redis에서 코드 삭제
        redisService.deleteData("AUTH_CODE:" + email);

        return true;

    }

    // 3. 회원가입
    @Transactional
    public ResponseEntity<?> join(JoinRequest request) {
        // 1. 최종 중복 검사 (인증 후 그 사이에 누군가 가입했을 수도 있음)
        if (userPaliRepository.existsByEmail(request.email())) {
            throw new UserException("이미 가입된 이메일입니다.", HttpStatus.CONFLICT);
        }

        // 2. 비밀번호 암호화 (보안 상 평문 저장 금지)
        String encodedPassword = passwordEncoder.encode(request.password());

        // 3. UserPali 엔티티 생성
        UserPali newUser = UserPali.builder()
                .email(request.email())
                .password(encodedPassword)
                .name(request.name())
                .phoneNumber(request.phoneNumber())
                .countryCode(request.countryCode())
                .status(UserStatus.ACTIVE) // 가입 즉시 활성화 상태로 설정
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();

        // 4. DB 저장
        userPaliRepository.save(newUser);

        // 5. 성공 시 201 Created와 함께 ID 반환
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(newUser.getUserId());
    }

    // 6자리 인증 코드 생성
    private String generateAuthCode() {
        String characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        SecureRandom random = new SecureRandom();
        StringBuilder sb = new StringBuilder(6);

        for (int i = 0; i < 6; i++) {
            sb.append(characters.charAt(random.nextInt(characters.length())));
        }

        return sb.toString();
    }
}
