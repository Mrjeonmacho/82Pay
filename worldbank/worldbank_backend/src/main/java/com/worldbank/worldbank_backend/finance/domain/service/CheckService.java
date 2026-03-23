package com.worldbank.worldbank_backend.finance.domain.service;

import com.worldbank.worldbank_backend.finance.domain.dto.Check.CheckRequestDto;
import com.worldbank.worldbank_backend.finance.domain.dto.Check.CheckResponseDto;
import com.worldbank.worldbank_backend.finance.domain.dto.Link.LinkRequestDto;
import com.worldbank.worldbank_backend.finance.domain.dto.Link.LinkResponseDto;
import com.worldbank.worldbank_backend.finance.domain.repository.kr.BankKRRepository;
import com.worldbank.worldbank_backend.finance.domain.router.BankRouter;
import com.worldbank.worldbank_backend.finance.domain.strategy.BankStrategy;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class CheckService {

    private final BankRouter bankRouter;
    private final BankKRRepository bankKRRepository;

    @Transactional(readOnly = true)
    public CheckResponseDto checkAccount(CheckRequestDto request) {
        BankStrategy strategy = bankRouter.route(request.getTargetCurrency());
        return strategy.checkAccount(request.getTargetAccountNumber());
    }

    @Transactional(readOnly = true)
    public CheckResponseDto getAmountByUserId(Long userId) {
        return bankKRRepository.findByUserId(userId)
                .map(account -> CheckResponseDto.builder()
                        .message("사용자 계좌 조회가 성공했습니다.")
                        .amount(account.getAmount())
                        .currency("KRW")
                        .check(true)
                        .build())
                .orElse(CheckResponseDto.builder()
                        .message("존재하지 않는 사용자 계좌입니다.")
                        .amount(null)
                        .currency(null)
                        .check(false)
                        .build());
    }

    @Transactional(readOnly = true)
    public LinkResponseDto linkAccount(LinkRequestDto request){
        BankStrategy strategy = bankRouter.route(request.getTargetCurrency());
        return strategy.linkAccount(request.getTargetAccountNumber(), request.getTargetAccountPassword());
    }
}
