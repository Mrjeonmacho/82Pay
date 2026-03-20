package com.worldbank.worldbank_backend.finance.domain.service;

import com.worldbank.worldbank_backend.finance.domain.dto.Check.CheckResponseDto;
import com.worldbank.worldbank_backend.finance.domain.entity.kr.BankKR;
import com.worldbank.worldbank_backend.finance.domain.repository.kr.BankKRRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class CheckService {

    private final BankKRRepository bankKRRepository;

    @Transactional(readOnly = true)
    public CheckResponseDto checkAccount(String accountNumber) {
        return bankKRRepository.findByAccountNumber(accountNumber)
                .map(account -> CheckResponseDto.builder()
                        .message("계좌 조회가 성공했습니다.")
                        .amount(account.getAmount())
                        .currency("KRW")
                        .check(true)
                        .build())
                .orElse(CheckResponseDto.builder()
                        .message("존재하지 않는 계좌입니다.")
                        .amount(null)
                        .currency(null)
                        .check(false)
                        .build());
    }
}
