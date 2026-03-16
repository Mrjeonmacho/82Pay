package com.worldbank.worldbank_backend.finance;

import com.worldbank.worldbank_backend.finance.domain.dto.Business.BusinessResponseDto;
import com.worldbank.worldbank_backend.finance.domain.service.BusinessService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
public class BusinessInfoTest {

    @Autowired
    private BusinessService businessService;

    @Test
    @DisplayName("사업자 정보 조회 테스트: 계좌번호로 사업자 상호명과 대표자명을 정확히 가져오는지 확인")
    void getBusinessInfoTest() {
        // Given: DB에 등록된 한국 사업자 계좌번호 (미리 등록해두신 것으로 테스트)
        String accountNumber = "KR-1001-0001";

        // When
        BusinessResponseDto response = businessService.getBusinessInfo(accountNumber);

        // Then
        assertThat(response.getMessage()).contains("성공");
        assertThat(response.getData()).isNotNull();
        System.out.println("조회된 상호명: " + response.getData().getCompanyName());
        System.out.println("조회된 대표자: " + response.getData().getBusinessPerson());
    }
}
