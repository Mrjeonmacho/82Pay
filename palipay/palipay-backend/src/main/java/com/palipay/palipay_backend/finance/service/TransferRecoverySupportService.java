package com.palipay.palipay_backend.finance.service;

import com.palipay.palipay_backend.finance.dto.ExternalTransferResultDto;
import com.palipay.palipay_backend.finance.dto.request.FinanceTransferRequest;
import org.springframework.stereotype.Service;

//TODO 구체화 구현
@Service
public class TransferRecoverySupportService {

    public void onExternalSuccessBeforePersist(
            Long userId,
            String idempotencyKey,
            FinanceTransferRequest request,
            ExternalTransferResultDto externalTransferResult
    ) {
    }

    public void onPersistSuccess(
            Long userId,
            String idempotencyKey,
            FinanceTransferRequest request,
            ExternalTransferResultDto externalTransferResult
    ) {
    }

    public void onPersistFailure(
            Long userId,
            String idempotencyKey,
            FinanceTransferRequest request,
            ExternalTransferResultDto externalTransferResult,
            Exception exception
    ) {
    }
}