package com.palipay.palipay_backend.finance.controller;

import com.palipay.palipay_backend.finance.dto.request.FinanceAdjustmentRequest;
import com.palipay.palipay_backend.finance.dto.request.FinanceTransferRequest;
import com.palipay.palipay_backend.finance.dto.response.FinanceAdjustmentResponse;
import com.palipay.palipay_backend.finance.dto.response.FinanceTransferResponse;
import com.palipay.palipay_backend.finance.service.FinanceChargeService;
import com.palipay.palipay_backend.finance.service.FinanceRefundService;
import com.palipay.palipay_backend.finance.service.FinanceTransferService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/finance")
@RequiredArgsConstructor
public class FinanceController {
    private final FinanceTransferService financeTransferService;
    private final FinanceChargeService financeChargeService;
    private final FinanceRefundService financeRefundService;

    @PostMapping("/transfers")
    public ResponseEntity<FinanceTransferResponse> transfer(
            @RequestHeader(value = "accesstoken", required = false) String accessToken,
            @RequestHeader(value = "Idempotency-Key", required = false) String idempotencyKey,
            @Valid @RequestBody FinanceTransferRequest request
    ) {

        //FIXME userId filter에서 받기
        Long userId = 1L;

        FinanceTransferResponse response = financeTransferService.transfer(
                userId,
                idempotencyKey,
                request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/charges")
    public ResponseEntity<FinanceAdjustmentResponse> charge(
            @RequestHeader(value = "accesstoken", required = false) String accessToken,
            @RequestHeader(value = "Idempotency-Key", required = false) String idempotencyKey,
            @Valid @RequestBody FinanceAdjustmentRequest request
    ){
        Long userId = 1L;
        FinanceAdjustmentResponse response = financeChargeService.charge(
                userId,
                idempotencyKey,
                request
        );
        return ResponseEntity.ok(response);
    }

    @PostMapping("/refunds")
    public ResponseEntity<FinanceAdjustmentResponse> refund(
            @RequestHeader(value = "accesstoken", required = false) String accessToken,
            @RequestHeader(value = "Idempotency-Key", required = false) String idempotencyKey,
            @Valid @RequestBody FinanceAdjustmentRequest request
    ){
        Long userId = 1L;
        FinanceAdjustmentResponse response = financeRefundService.refund(
                userId,
                idempotencyKey,
                request
        );
        return ResponseEntity.ok(response);
    }
}
