package com.worldbank.worldbank_backend.finance.domain.service;

import com.worldbank.worldbank_backend.finance.domain.dto.TransferRequestDto;
import com.worldbank.worldbank_backend.finance.domain.dto.TransferResponseDto;
import com.worldbank.worldbank_backend.finance.domain.router.BankRouter;
import com.worldbank.worldbank_backend.finance.domain.strategy.BankStrategy;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class TransferService {

    private final BankRouter bankRouter;

    @Transactional
    public TransferResponseDto transfer(TransferRequestDto request) {

        BankStrategy senderBank = bankRouter.route(request.getSenderBankcode());
        BankStrategy targetBank = bankRouter.route(request.getTargetBankcode());

        // 출금
        senderBank.withdraw(request);

        // 입금
        targetBank.deposit(request);

        return TransferResponseDto.builder()
                .message("이체가 정상적으로 완료되었습니다.")
                .senderAccountNumber(request.getSenderAccountNumber())
                .targetAccountNumber(request.getTargetAccountNumber())
                .senderAmount(request.getSenderAmount())
                .targetAmount(request.getTargetAmount())
                .build();
    }
}
