package com.palipay.palipay_backend.finance.service;

import com.palipay.palipay_backend.finance.domain.AccountHistory;
import com.palipay.palipay_backend.finance.domain.TransactionCategory;
import com.palipay.palipay_backend.finance.domain.WalletPali;
import com.palipay.palipay_backend.finance.dto.ExternalTransferResultDto;
import com.palipay.palipay_backend.finance.dto.FinanceCommonDto;
import com.palipay.palipay_backend.finance.dto.TransferPersistResultDto;
import com.palipay.palipay_backend.global.bank.BankCode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

@Service
@RequiredArgsConstructor
public class TransferCommonPersistenceService {
    private final WalletService walletService;
    private final AccountHistoryService accountHistoryService;

    @Transactional
    public TransferPersistResultDto persist(
            Long userId,
            Long walletId,
            Long workplaceId,
            FinanceCommonDto financeCommandDto,
            ExternalTransferResultDto externalTransferResultDto
    ) {
        WalletPali walletPali = null;

        String accountNumber = "";
        String accountName = "";
        BankCode bankCode = null;
        BigDecimal amount = BigDecimal.ZERO;
        BigDecimal exchangeRate = BigDecimal.ONE;

        TransactionCategory category = financeCommandDto.transactionCategory();

        if (category == TransactionCategory.INPUT) {
            accountNumber = financeCommandDto.sourceAccountNumber();
            accountName = financeCommandDto.sourceAccountName();
            bankCode = financeCommandDto.sourceBankCode();

            //FIXME 원화여야 하니까 액수는 target이 맞을거 같음
            amount = financeCommandDto.targetAmount();
            walletPali = walletService.credit(walletId, amount);
        }
        else if (category == TransactionCategory.OUTPUT) {
            accountNumber = financeCommandDto.targetAccountNumber();
            accountName = financeCommandDto.targetAccountName();
            bankCode = financeCommandDto.targetBankCode();

            //FIXME 원화여야 하니까 액수는 source가 맞을거 같음
            amount = financeCommandDto.sourceAmount();
            walletPali = walletService.debit(walletId, amount);
        } else {
            throw new IllegalArgumentException("지원하지 않는 거래 유형입니다. category=" + category);
        }

        if (bankCode == null) {
            throw new IllegalArgumentException("은행 코드가 설정되지 않았습니다.");
        }


        AccountHistory savedHistory = accountHistoryService.createHistory(
                userId,
                walletPali,
                financeCommandDto.transactionCategory(),
                accountNumber,
                accountName,
                financeCommandDto.description(),
                bankCode,
                amount,
                workplaceId,
                exchangeRate
        );

        return new TransferPersistResultDto(
                savedHistory.getHistoryId(),
                walletPali.getAmount(),
                savedHistory.getCreatedAt()
        );
    }
}
