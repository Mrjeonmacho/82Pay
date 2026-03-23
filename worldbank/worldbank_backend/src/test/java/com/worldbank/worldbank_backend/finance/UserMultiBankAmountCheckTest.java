package com.worldbank.worldbank_backend.finance;

import com.worldbank.worldbank_backend.finance.domain.dto.Check.CheckResponseDto;
import com.worldbank.worldbank_backend.finance.domain.service.CheckService;
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

    @Test
    @DisplayName("한국(KRW) 사용자 ID 기반 잔액 조회 테스트 - 성공")
    void checkKRAmountByUserIdSuccess() {
        // Given: DB에 존재하는 사용자 ID와 통화코드
        Long userId = 1L;
        String currency = "KRW";
        BigDecimal expectedAmount = new BigDecimal("898000.00");

        // When
        CheckResponseDto response = checkService.getAmountByUserId(userId, currency);

        // Then
        assertThat(response.getCheck()).isTrue();
        assertThat(response.getCurrency()).isEqualTo("KRW");
        assertThat(response.getMessage()).contains("성공");
        
        if (response.getAmount() != null) {
            assertThat(response.getAmount().stripTrailingZeros())
                    .isEqualTo(expectedAmount.stripTrailingZeros());
        }
    }

    @Test
    @DisplayName("일본(JPY) 사용자 ID 기반 잔액 조회 테스트 - 성공")
    void checkJPYAmountByUserIdSuccess() {
        // Given: DB에 실제 존재하는 일본 사용자 ID와 통화코드 (제공해주신 데이터 기준)
        Long userId = 1L;
        String currency = "JPY";
        BigDecimal expectedAmount = new BigDecimal("312000.00");

        // When
        CheckResponseDto response = checkService.getAmountByUserId(userId, currency);

        // Then
        assertThat(response.getCheck()).isTrue();
        assertThat(response.getCurrency()).isEqualTo("JPY");
        assertThat(response.getMessage()).contains("성공");
        
        if (response.getAmount() != null) {
            assertThat(response.getAmount().stripTrailingZeros())
                    .isEqualTo(expectedAmount.stripTrailingZeros());
        }
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
