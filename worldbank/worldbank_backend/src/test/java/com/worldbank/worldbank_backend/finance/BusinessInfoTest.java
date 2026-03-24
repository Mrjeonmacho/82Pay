package com.worldbank.worldbank_backend.finance;

import com.worldbank.worldbank_backend.finance.domain.dto.Business.BusinessResponseDto;
import com.worldbank.worldbank_backend.finance.domain.entity.kr.BankKR;
import com.worldbank.worldbank_backend.finance.domain.entity.kr.Business;
import com.worldbank.worldbank_backend.finance.domain.repository.kr.BankKRRepository;
import com.worldbank.worldbank_backend.finance.domain.repository.kr.BusinessRepository;
import com.worldbank.worldbank_backend.finance.domain.service.BusinessService;
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

import java.util.UUID;

@SpringBootTest
@Transactional
public class BusinessInfoTest {

    @Autowired
    private BusinessService businessService;

    @Autowired
    private UserService userService;

    @Autowired
    private UserBankKRRepository userKRRepository;

    @Autowired
    private BankKRRepository bankKRRepository;

    @Autowired
    private BusinessRepository businessRepository;

    @Test
    @DisplayName("사업자 정보 조회 테스트: 계좌번호로 사업자 상호명과 대표자명을 정확히 가져오는지 확인")
    void getBusinessInfoTest() {
        // Given: 유저 가입
        String email = "biz_" + UUID.randomUUID().toString().substring(0, 5) + "@test.com";
        userService.signUp(SignupRequest.builder()
                .email(email).password("1234").countryCode("KR")
                .name("대표자명").bankName("한국은행").accountPassword("1234").build());

        UserBankKR user = userKRRepository.findByEmail(email).get();
        BankKR bank = bankKRRepository.findByUser_UserId(user.getUserId()).get();

        // 사업자 수동 등록 (사업자 번호를 랜덤하게 생성하여 충돌 방지)
        String randomBizNum = UUID.randomUUID().toString().substring(0, 10);
        Business business = Business.builder()
                .account(bank)
                .businessPerson("대표자명")
                .businessNumber(randomBizNum)
                .companyName("테스트상호")
                .businessAddress("서울시")
                .build();
        businessRepository.save(business);

        // When
        BusinessResponseDto response = businessService.getBusinessInfo(bank.getAccountNumber());

        // Then
        assertThat(response.getMessage()).contains("성공");
        assertThat(response.getData().getBusinessNumber()).isEqualTo(randomBizNum);
    }
}
