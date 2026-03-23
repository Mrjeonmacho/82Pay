package com.worldbank.worldbank_backend.finance.domain.service;

import com.worldbank.worldbank_backend.finance.domain.dto.Check.CheckRequestDto;
import com.worldbank.worldbank_backend.finance.domain.dto.Check.CheckResponseDto;
import com.worldbank.worldbank_backend.finance.domain.dto.Link.LinkRequestDto;
import com.worldbank.worldbank_backend.finance.domain.dto.Link.LinkResponseDto;
import com.worldbank.worldbank_backend.finance.domain.router.BankRouter;
import com.worldbank.worldbank_backend.finance.domain.strategy.BankStrategy;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class CheckService {

    private final BankRouter bankRouter;

    @Transactional(readOnly = true)
    public CheckResponseDto checkAccount(CheckRequestDto request) {
        BankStrategy strategy = bankRouter.route(request.getTargetCurrency());
        return strategy.checkAccount(request.getTargetAccountNumber());
    }

    @Transactional(readOnly = true)
    public LinkResponseDto linkAccount(LinkRequestDto request){
        BankStrategy strategy = bankRouter.route(request.getTargetCurrency());
        return strategy.linkAccount(request.getTargetAccountNumber(), request.getTargetAccountPassword());
    }
}
