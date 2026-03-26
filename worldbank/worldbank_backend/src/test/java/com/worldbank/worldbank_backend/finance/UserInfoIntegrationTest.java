package com.worldbank.worldbank_backend.finance;

import com.worldbank.worldbank_backend.finance.domain.dto.Info.InfoResponseDto;
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

import java.math.BigDecimal;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@Transactional
public class UserInfoIntegrationTest {

    @Autowired
    private CheckService checkService;

    @Autowired
    private UserService userService;

    @Autowired
    private UserBankKRRepository userKRRepository;

    @Autowired
    private BankKRRepository bankKRRepository;

    @Test
    @DisplayName("사용자 내 정보 조회 테스트 - DB 실데이터 기반 정밀 검증")
    void getUserInfoDeepSuccess() {
        // Given: 제공해주신 '이월드'님 시나리오로 가입
        String email = "eworld_" + UUID.randomUUID().toString().substring(0, 5) + "@test.com";
        String name = "이월드";
        String bankName = "신한은행";
        
        userService.signUp(SignupRequest.builder()
                .email(email)
                .password("hashed_password_1234")
                .countryCode("KR")
                .name(name)
                .bankName(bankName)
                .accountPassword("1234")
                .build());

        // 가입된 유저와 계좌 정보를 DB에서 직접 조회 (원본 데이터)
        UserBankKR user = userKRRepository.findByEmail(email).orElseThrow();
        BankKR actualBank = bankKRRepository.findByUser_UserId(user.getUserId()).orElseThrow();

        // When: 정보 조회 API 호출
        InfoResponseDto response = checkService.getInfo(user.getUserId(), "KRW");

        // Then: DB 원본 데이터와 API 응답 데이터가 100% 일치하는지 정밀 비교
        assertThat(response).isNotNull();
        
        // 1. 사용자 이름 일치 확인 (이월드)
        assertThat(response.getUserName()).isEqualTo(actualBank.getUserName());
        
        // 2. 랜덤하게 생성된 계좌번호가 DB와 동일한지 확인
        assertThat(response.getAccountNumber()).isEqualTo(actualBank.getAccountNumber());
        
        // 3. 잔액 검증 (1,000,000원)
        assertThat(response.getAmount().stripTrailingZeros())
                .isEqualByComparingTo(actualBank.getAmount().stripTrailingZeros());
        
        // 4. 은행명 및 통화 일치 확인
        assertThat(response.getBankName()).isEqualTo(actualBank.getBankName());
        assertThat(response.getCurrency()).isEqualTo("KRW");

        System.out.println("검증 완료 - 계좌번호: " + response.getAccountNumber());
    }

    @Test
    @DisplayName("존재하지 않는 사용자 정보 조회 시 예외 발생")
    void getUserInfoFail() {
        // Given: 존재하지 않는 유저 ID
        Long invalidUserId = 999999L;
        String currency = "KRW";

        // When & Then
        try {
            checkService.getInfo(invalidUserId, currency);
        } catch (RuntimeException e) {
            assertThat(e.getMessage()).contains("찾을 수 없습니다");
        }
    }
}
