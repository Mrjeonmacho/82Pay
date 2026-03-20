package com.palipay.palipay_backend.finance.service;

import com.palipay.palipay_backend.external.dto.response.ExternalWorkplaceResponse;
import com.palipay.palipay_backend.external.service.ExternalBankClient;
import com.palipay.palipay_backend.finance.domain.Workplace;
import com.palipay.palipay_backend.finance.repository.WorkplaceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class WorkplaceService {
    private final WorkplaceRepository workplaceRepository;

    private final ExternalBankClient externalBankClient;

    public Long getWorkplaceId(String accountNumber){
        /*ExternalWorkplaceResponse workplaceInfo(String accountNumber)*/

        ExternalWorkplaceResponse response = externalBankClient.workplaceInfo(accountNumber);

        /*TODO response 가 에러일 경우*/
        if (response == null) {
            throw new IllegalArgumentException("외부 사업장 조회 응답이 없습니다.");
        }
        //db에 존재한다면 id 가져오고 없다면 저장
        return workplaceRepository.findByBusinessNumber(response.businessNumber())
                .map(Workplace::getWorkplaceId)
                .orElseGet(() -> createWorkplace(response).getWorkplaceId());
    }

    private Workplace createWorkplace(ExternalWorkplaceResponse response) {
        Workplace workplace = Workplace.builder()
                .location(response.businessAddress())
                .companyName(response.companyName())
                .businessNumber(response.businessNumber())
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();

        return workplaceRepository.save(workplace);
    }
}
