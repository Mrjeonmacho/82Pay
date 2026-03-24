package com.worldbank.worldbank_backend.finance;

import com.worldbank.worldbank_backend.finance.domain.dto.Check.CheckResponseDto;
import com.worldbank.worldbank_backend.finance.domain.service.CheckService;
import com.worldbank.worldbank_backend.user.dto.request.SignupRequest;
import com.worldbank.worldbank_backend.user.entity.kr.UserBankKR;
import com.worldbank.worldbank_backend.user.entity.jp.UserBankJP;
import com.worldbank.worldbank_backend.user.repository.kr.UserBankKRRepository;
import com.worldbank.worldbank_backend.user.repository.jp.UserBankJPRepository;
import com.worldbank.worldbank_backend.user.service.UserService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@Transactional
public class UserMultiBankAmountCheckTest {

    @Autowired
    private CheckService checkService;

    @Autowired
    private UserService userService;

    @Autowired
    private UserBankKRRepository userBankKRRepository;

    @Autowired
    private UserBankJPRepository userBankJPRepository;

    @BeforeEach
    void setUp() {
        // 한국 유저 가입 (계좌 + 축하금 1,000,000 자동 생성)
        SignupRequest krSignup = SignupRequest.builder()
                .email("test-kr@worldbank.com")
                .password("1234")
                .countryCode("KR")
                .name("김민수")
                .bankName("한국은행")
                .accountPassword("1234")
                .build();
        userService.signUp(krSignup);

        // 일본 유저 가입 (계좌 + 축하금 100,000 자동 생성)
        SignupRequest jpSignup = SignupRequest.builder()
                .email("test-jp@worldbank.com")
                .password("1234")
                .countryCode("JP")
                .name("Tanaka Taro")
                .bankName("도쿄은행")
                .accountPassword("1234")
                .build();
        userService.signUp(jpSignup);
    }

    @Test
    @DisplayName("한국(KRW) 사용자 ID 기반 잔액 조회 테스트 - 성공")
    void checkKRAmountByUserIdSuccess() {
        UserBankKR user = userBankKRRepository.findByEmail("test-kr@worldbank.com").orElseThrow();
        Long userId = user.getUserId();
        String currency = "KRW";
        BigDecimal expectedAmount = new BigDecimal("1000000.00");

        // When
        CheckResponseDto response = checkService.getAmountByUserId(userId, currency);

        // Then
        assertThat(response.getCheck()).isTrue();
        assertThat(response.getCurrency()).isEqualTo("KRW");
        
        if (response.getAmount() != null) {
            assertThat(response.getAmount().stripTrailingZeros())
                    .isEqualTo(expectedAmount.stripTrailingZeros());
        }
    }

    @Test
    @DisplayName("일본(JPY) 사용자 ID 기반 잔액 조회 테스트 - 성공")
    void checkJPYAmountByUserIdSuccess() {
        UserBankJP user = userBankJPRepository.findByEmail("test-jp@worldbank.com").orElseThrow();
        Long userId = user.getUserId();
        String currency = "JPY";
        BigDecimal expectedAmount = new BigDecimal("100000.00"); // 일본 축하금 10만엔

        // When
        CheckResponseDto response = checkService.getAmountByUserId(userId, currency);

        // Then
        assertThat(response.getCheck()).isTrue();
        assertThat(response.getCurrency()).isEqualTo("JPY");
    }

    @Test
    @DisplayName("지원하지 않는 통화로 조회 시 예외 발생 확인 (라우팅 실패)")
    void checkUnsupportedCurrencyByUserId() {
        // Given
        Long userId = 1L;
        String unsupportedCurrency = "EUR"; // 지원하지 않는 유로화

        // When & Then
        try {
            checkService.getAmountByUserId(userId, unsupportedCurrency);
        } catch (RuntimeException e) {
            assertThat(e.getMessage()).contains("지원하지 않는 은행");
        }
    }

    @Test
    @DisplayName("유효하지 않은 사용자 ID 조회 테스트")
    void checkInvalidUserAmount() {
        // Given: 존재하지 않는 사용자 ID
        Long nonExistentUserId = 999999L;
        String currency = "KRW";

        // When
        CheckResponseDto response = checkService.getAmountByUserId(nonExistentUserId, currency);

        // Then
        assertThat(response.getCheck()).isFalse();
        assertThat(response.getMessage()).contains("존재하지 않는 사용자 계좌");
    }
}
