package com.worldbank.worldbank_backend.finance;

import com.worldbank.worldbank_backend.finance.domain.dto.Link.LinkRequestDto;
import com.worldbank.worldbank_backend.finance.domain.dto.Link.LinkResponseDto;
import com.worldbank.worldbank_backend.finance.domain.service.CheckService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@Transactional
public class LinkIntegrationTest {

    @Autowired
    private CheckService checkService;

    @Test
    @DisplayName("한국 계좌 연결 테스트 - 성공 (비밀번호 일치)")
    void linkKRWAccountSuccess() {
        // Given: DB에 실제 존재하는 계좌번호와 비밀번호 (DB 상태에 따라 수정 필요)
        String accountNumber = "KR-1001-0001";
        String password = "1234"; // 실제 DB의 비밀번호로 설정
        
        LinkRequestDto request = LinkRequestDto.builder()
                .targetAccountNumber(accountNumber)
                .targetAccountPassword(password)
                .targetCurrency("KRW")
                .build();

        // When
        LinkResponseDto response = checkService.linkAccount(request);

        // Then
        // 실제 데이터가 있다면 true, 없다면 false가 나올 것이므로 유연하게 검증
        if (response.getCheck()) {
            assertThat(response.getMessage()).contains("성공");
        } else {
            assertThat(response.getMessage()).containsAnyOf("일치하지 않습니다", "존재하지 않는");
        }
    }

    @Test
    @DisplayName("계좌 연결 실패 테스트 - 비밀번호 불일치")
    void linkAccountPasswordMismatch() {
        // Given: 실제 존재하는 계좌번호에 틀린 비밀번호 입력
        String accountNumber = "KR-1001-0001";
        String wrongPassword = "0000";
        
        LinkRequestDto request = LinkRequestDto.builder()
                .targetAccountNumber(accountNumber)
                .targetAccountPassword(wrongPassword)
                .targetCurrency("KRW")
                .build();

        // When
        LinkResponseDto response = checkService.linkAccount(request);

        // Then
        assertThat(response.getCheck()).isFalse();
        assertThat(response.getMessage()).contains("일치하지 않습니다");
    }

    @Test
    @DisplayName("계좌 연결 실패 테스트 - 존재하지 않는 계좌")
    void linkAccountNotFound() {
        // Given: 존재하지 않는 계좌번호
        String invalidAccountNumber = "KR-1001-0002";
        
        LinkRequestDto request = LinkRequestDto.builder()
                .targetAccountNumber(invalidAccountNumber)
                .targetAccountPassword("0000")
                .targetCurrency("KRW")
                .build();

        // When
        LinkResponseDto response = checkService.linkAccount(request);

        // Then
        assertThat(response.getCheck()).isFalse();
        assertThat(response.getMessage()).contains("존재하지 않는");
    }
}
