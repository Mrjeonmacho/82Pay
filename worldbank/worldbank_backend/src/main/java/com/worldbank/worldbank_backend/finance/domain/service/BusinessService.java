package com.worldbank.worldbank_backend.finance.domain.service;

import com.worldbank.worldbank_backend.finance.domain.dto.Business.BusinessResponseDto;
import com.worldbank.worldbank_backend.finance.domain.entity.kr.Business;
import com.worldbank.worldbank_backend.finance.domain.repository.kr.BusinessRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class BusinessService {

    private final BusinessRepository businessRepository;

    public BusinessResponseDto getBusinessInfo(String accountNumber) {
        Business business = businessRepository.findByAccount_AccountNumber(accountNumber)
                .orElseThrow(() -> new RuntimeException("사업자 정보를 찾을 수 없습니다."));

        return BusinessResponseDto.builder()
                .message("사업자 조회가 성공했습니다.")
                .data(BusinessResponseDto.BusinessData.builder()
                        .companyName(business.getCompanyName())
                        .businessPerson(business.getBusinessPerson())
                        .businessNumber(business.getBusinessNumber())
                        .businessAddress(business.getBusinessAddress())
                        .build())
                .build();
    }
}
