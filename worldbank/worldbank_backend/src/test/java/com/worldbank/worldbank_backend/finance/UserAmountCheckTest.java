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
public class UserAmountCheckTest {

    @Autowired
    private CheckService checkService;

    @Test
    @DisplayName("사용자 ID 기반 잔액 조회 테스트 - 성공")
    void checkAmountByUserIdSuccess() {
        // Given: DB에 실제 존재하는 사용자 ID (제시해주신 데이터 기준)
        Long userId = 1L;
        BigDecimal expectedAmount = new BigDecimal("898000.00");

        // When
        CheckResponseDto response = checkService.getAmountByUserId(userId);

        // Then
        assertThat(response.getCheck()).isTrue();
        assertThat(response.getCurrency()).isEqualTo("KRW");
        assertThat(response.getMessage()).contains("성공");
        
        // 실제 DB 잔액이 예상값과 일치하는지 확인 (DB 상태에 따라 다를 수 있음)
        if (response.getAmount() != null) {
            assertThat(response.getAmount().stripTrailingZeros())
                    .isEqualTo(expectedAmount.stripTrailingZeros());
        }
    }

    @Test
    @DisplayName("사용자 ID 기반 잔액 조회 테스트 - 실패 (존재하지 않는 유저)")
    void checkAmountByUserIdFail() {
        // Given: DB에 존재하지 않는 임의의 사용자 ID
        Long nonExistentUserId = 9999L;

        // When
        CheckResponseDto response = checkService.getAmountByUserId(nonExistentUserId);

        // Then
        assertThat(response.getCheck()).isFalse();
        assertThat(response.getAmount()).isNull();
        assertThat(response.getMessage()).contains("존재하지 않는");
    }
}
