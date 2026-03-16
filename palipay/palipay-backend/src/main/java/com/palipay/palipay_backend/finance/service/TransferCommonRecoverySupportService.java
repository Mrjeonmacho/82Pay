package com.palipay.palipay_backend.finance.service;

import com.palipay.palipay_backend.finance.dto.ExternalTransferResultDto;
import com.palipay.palipay_backend.finance.dto.FinanceCommonDto;
import com.palipay.palipay_backend.finance.dto.request.FinanceTransferRequest;
import org.springframework.stereotype.Service;

@Service
public class TransferCommonRecoverySupportService {

    public void onExternalSuccessBeforePersist(
            Long userId,
            String idempotencyKey,
            FinanceCommonDto request,
            ExternalTransferResultDto externalTransferResult
    ) {
    }

    public void onPersistSuccess(
            Long userId,
            String idempotencyKey,
            FinanceCommonDto request,
            ExternalTransferResultDto externalTransferResult
    ) {
    }

    public void onPersistFailure(
            Long userId,
            String idempotencyKey,
            FinanceCommonDto request,
            ExternalTransferResultDto externalTransferResult,
            Exception exception
    ) {
    }
}
