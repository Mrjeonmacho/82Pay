package com.worldbank.worldbank_backend.finance.domain.service;

import com.worldbank.worldbank_backend.finance.domain.dto.Transfer.TransferRequestDto;
import com.worldbank.worldbank_backend.finance.domain.dto.Transfer.TransferResponseDto;
import com.worldbank.worldbank_backend.finance.domain.router.BankRouter;
import com.worldbank.worldbank_backend.finance.domain.strategy.BankStrategy;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class TransferService {

    private final BankRouter bankRouter;

    @Transactional(rollbackFor = Exception.class)
    public TransferResponseDto transfer(TransferRequestDto request) {

        BankStrategy senderBank = bankRouter.route(request.getSenderBankcode());
        BankStrategy targetBank = bankRouter.route(request.getTargetBankcode());

        // 출금
        senderBank.withdraw(request);

        // 입금
        targetBank.deposit(request);

        // 3. 여기서 강제로 터뜨림!!
//        if (true) throw new RuntimeException("분산 트랜잭션 롤백  테스트");

        return TransferResponseDto.builder()
                .message("이체가 정상적으로 완료되었습니다.")
                .senderAccountNumber(request.getSenderAccountNumber())
                .senderAccountName(request.getSenderAccountName())
                .senderBankcode(request.getSenderBankcode())
                .senderAmount(request.getSenderAmount())
                .senderCurrency(request.getSenderCurrency())
                .targetAccountNumber(request.getTargetAccountNumber())
                .targetAccountName(request.getTargetAccountName())
                .targetBankcode(request.getTargetBankcode())
                .targetAmount(request.getTargetAmount())
                .targetCurrency(request.getTargetCurrency())
                .build();
    }
}
