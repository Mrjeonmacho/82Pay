//package com.palipay.palipay_backend.finance.service;
//
//import com.palipay.palipay_backend.finance.domain.AccountHistory;
//import com.palipay.palipay_backend.finance.domain.WalletPali;
//import com.palipay.palipay_backend.finance.dto.ExternalTransferResultDto;
//import com.palipay.palipay_backend.finance.dto.TransferPersistResultDto;
//import com.palipay.palipay_backend.finance.dto.request.FinanceTransferRequest;
//import com.palipay.palipay_backend.finance.repository.AccountHistoryRepository;
//import jakarta.transaction.Transactional;
//import lombok.RequiredArgsConstructor;
//import org.springframework.stereotype.Service;
//
//@Service
//@RequiredArgsConstructor
//public class TransferPersistenceService {
//    private final WalletDebitService walletDebitService;
//    private final AccountHistoryService accountHistoryService;
//
//    @Transactional
//    public TransferPersistResultDto persist(
//            Long userId,
//            String idempotencyKey,
//            FinanceTransferRequest request,
//            ExternalTransferResultDto externalTransferResultDto
//    ){
//        WalletPali debitWallet = walletDebitService.debit(request.walletId(), request.amount());
//
//        AccountHistory accountHistory = accountHistoryService.createOutputHistory(
//                userId,
//                idempotencyKey,
//                debitWallet,
//                request,
//                externalTransferResultDto
//        );
//
//        //TODO 생성일자 오류도 생각해야 하는지?
//        if(accountHistory.getCreatedAt() == null){
//            throw new IllegalArgumentException("생성 오류 필요한지는 체크");
//        }
//
//        return new TransferPersistResultDto(
//                accountHistory.getHistoryId(),
//                debitWallet.getAmount(),
//                accountHistory.getCreatedAt()
//        );
//    }
//}
