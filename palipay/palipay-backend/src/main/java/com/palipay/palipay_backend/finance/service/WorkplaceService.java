package com.palipay.palipay_backend.finance.service;

import com.palipay.palipay_backend.external.dto.response.ExternalWorkplaceResponse;
import com.palipay.palipay_backend.external.service.ExternalBankClient;
import com.palipay.palipay_backend.finance.domain.Workplace;
import com.palipay.palipay_backend.finance.repository.WorkplaceRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class WorkplaceService {
    private final WorkplaceRepository workplaceRepository;

    private final ExternalBankClient externalBankClient;

    @Transactional
    public Optional<Long> getWorkplaceId(String accountNumber){
        /*ExternalWorkplaceResponse workplaceInfo(String accountNumber)*/

        Optional<ExternalWorkplaceResponse> responseOpt = externalBankClient.workplaceInfo(accountNumber);

        if (responseOpt.isEmpty()) {
            log.info("외부 사업장 조회 결과 없음. accountNumber={}", accountNumber);
            return Optional.empty();
        }

        ExternalWorkplaceResponse response = responseOpt.get();

        Long workplaceId = workplaceRepository.findByBusinessNumber(response.businessNumber())
                .map(Workplace::getWorkplaceId)
                .orElseGet(() -> createWorkplace(response).getWorkplaceId());

        return Optional.of(workplaceId);
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
