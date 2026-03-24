package com.worldbank.worldbank_backend.finance;

import com.worldbank.worldbank_backend.finance.domain.dto.Link.LinkRequestDto;
import com.worldbank.worldbank_backend.finance.domain.dto.Link.LinkResponseDto;
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
public class LinkIntegrationTest {

    @Autowired
    private CheckService checkService;

    @Autowired
    private UserService userService;

    @Autowired
    private UserBankKRRepository userKRRepository;

    @Autowired
    private BankKRRepository bankKRRepository;

    @Test
    @DisplayName("한국 계좌 연결 테스트 - 성공 (비밀번호 일치)")
    void linkKRWAccountSuccess() {
        // Given: 실제 유저 가입
        userService.signUp(SignupRequest.builder()
                .email("link@test.com").password("1234").countryCode("KR")
                .name("이연결").bankName("한국은행").accountPassword("1234").build());

        UserBankKR user = userKRRepository.findByEmail("link@test.com").get();
        BankKR bank = bankKRRepository.findByUser_UserId(user.getUserId()).get();
        
        LinkRequestDto request = LinkRequestDto.builder()
                .targetAccountNumber(bank.getAccountNumber())
                .targetAccountPassword("1234")
                .targetCurrency("KRW")
                .build();

        // When
        LinkResponseDto response = checkService.linkAccount(request);

        // Then
        assertThat(response.getCheck()).isTrue();
        assertThat(response.getMessage()).contains("성공");
    }

    @Test
    @DisplayName("계좌 연결 실패 테스트 - 비밀번호 불일치")
    void linkAccountPasswordMismatch() {
        // Given
        userService.signUp(SignupRequest.builder()
                .email("link_fail@test.com").password("1234").countryCode("KR")
                .name("김실패").bankName("한국은행").accountPassword("1234").build());

        UserBankKR user = userKRRepository.findByEmail("link_fail@test.com").get();
        BankKR bank = bankKRRepository.findByUser_UserId(user.getUserId()).get();
        
        LinkRequestDto request = LinkRequestDto.builder()
                .targetAccountNumber(bank.getAccountNumber())
                .targetAccountPassword("0000") // 틀린 비밀번호
                .targetCurrency("KRW")
                .build();

        // When
        LinkResponseDto response = checkService.linkAccount(request);

        // Then
        assertThat(response.getCheck()).isFalse();
        assertThat(response.getMessage()).contains("비밀번호가 일치하지 않습니다");
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
