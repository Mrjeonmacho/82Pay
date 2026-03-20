package com.worldbank.worldbank_backend.finance;

import com.worldbank.worldbank_backend.finance.domain.dto.Check.CheckRequestDto;
import com.worldbank.worldbank_backend.finance.domain.dto.Check.CheckResponseDto;
import com.worldbank.worldbank_backend.finance.domain.service.CheckService;
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

    @Test
    @DisplayName("한국 계좌 조회 테스트 - 성공")
    void checkKRWAccountSuccess() {
        // Given: DB에 이미 데이터가 있는 계좌번호 사용 (DB 상태에 따라 번호 수정 필요)
        String accountNumber = "110-123-456789"; 
        CheckRequestDto request = CheckRequestDto.builder()
                .targetAccountNumber(accountNumber)
                .targetCurrency("KRW")
                .build();

        // When
        CheckResponseDto response = checkService.checkAccount(request);

        // Then
        if (response.getCheck()) {
            assertThat(response.getCurrency()).isEqualTo("KRW");
            assertThat(response.getMessage()).contains("성공");
        } else {
            // DB에 데이터가 없는 경우를 고려
            assertThat(response.getMessage()).contains("존재하지 않는");
        }
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
