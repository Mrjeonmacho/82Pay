package com.worldbank.worldbank_backend.finance;

import com.worldbank.worldbank_backend.finance.domain.dto.Check.CheckRequestDto;
import com.worldbank.worldbank_backend.finance.domain.dto.Check.CheckResponseDto;
import com.worldbank.worldbank_backend.finance.domain.entity.kr.BankKR;
import com.worldbank.worldbank_backend.finance.domain.repository.kr.BankKRRepository;
import com.worldbank.worldbank_backend.finance.domain.service.CheckService;
import com.worldbank.worldbank_backend.user.dto.request.SignupRequest;
import com.worldbank.worldbank_backend.user.entity.kr.UserBankKR;
import com.worldbank.worldbank_backend.user.repository.kr.UserBankKRRepository;
import com.worldbank.worldbank_backend.user.service.UserService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@Transactional
public class CheckIntegrationTest {

    @Autowired
    private CheckService checkService;

    @Autowired
    private UserService userService;

    @Autowired
    private UserBankKRRepository userKRRepository;

    @Autowired
    private BankKRRepository bankKRRepository;

    @Test
    @DisplayName("한국 계좌 조회 테스트 - 성공")
    void checkKRWAccountSuccess() {
        // Given: 실제 유저 가입 및 계좌 생성
        userService.signUp(SignupRequest.builder()
                .email("check@test.com").password("1234").countryCode("KR")
                .name("김조회").bankName("한국은행").accountPassword("1234").build());

        UserBankKR user = userKRRepository.findByEmail("check@test.com").get();
        BankKR bank = bankKRRepository.findByUser_UserId(user.getUserId()).get();

        CheckRequestDto request = CheckRequestDto.builder()
                .targetAccountNumber(bank.getAccountNumber())
                .targetCurrency("KRW")
                .build();

        // When
        CheckResponseDto response = checkService.checkAccount(request);

        // Then
        assertThat(response.getCheck()).isTrue();
        assertThat(response.getCurrency()).isEqualTo("KRW");
        assertThat(response.getMessage()).contains("성공");
    }

    @Test
    @DisplayName("일본 계좌 조회 테스트 - 성공 여부 확인")
    void checkJPYAccount() {
        // Given
        CheckRequestDto request = CheckRequestDto.builder()
                .targetAccountNumber("999-888-777")
                .targetCurrency("JPY")
                .build();

        // When
        CheckResponseDto response = checkService.checkAccount(request);

        // Then
        // 현재 DB에 해당 계좌가 없다면 check는 false여야 함
        assertThat(response.getCurrency()).isNull();
        assertThat(response.getCheck()).isFalse();
    }

    @Test
    @DisplayName("지원하지 않는 통화 조회 시 예외 발생 확인")
    void checkUnsupportedCurrency() {
        // Given
        CheckRequestDto request = CheckRequestDto.builder()
                .targetAccountNumber("12345")
                .targetCurrency("EUR") // 지원하지 않는 유로화
                .build();

        // When & Then
        try {
            checkService.checkAccount(request);
        } catch (RuntimeException e) {
            assertThat(e.getMessage()).contains("지원하지 않는 은행");
        }
    }
}
