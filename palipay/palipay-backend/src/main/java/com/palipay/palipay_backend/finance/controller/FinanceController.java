package com.palipay.palipay_backend.finance.controller;

import com.palipay.palipay_backend.finance.dto.request.*;
import com.palipay.palipay_backend.finance.dto.response.*;
import com.palipay.palipay_backend.finance.service.*;
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

    private final FinanceValidationService financeValidationService;
    private final AccountHistoryService accountHistoryService;

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

    /*거래내역 조회*/
    @GetMapping("/transactions")
    public ResponseEntity<FinanceHistoryResponse> getTransactions(
            @RequestHeader(value = "accesstoken", required = false) String accessToken,
            @ModelAttribute FinanceHistoryRequest request
    ) {
        Long userId = 1L;
        FinanceHistoryResponse response
                = accountHistoryService.getTransactionHistories(userId, request);
        return ResponseEntity.ok(response);
    }

    /*지갑 잔액 체크*/
    @PostMapping("/balance/check")
    public ResponseEntity<BalanceCheckResponse> checkBalance(
            @RequestHeader(value = "accesstoken", required = false) String accessToken,
            @Valid @RequestBody BalanceCheckRequest request
    ){

        //FIXME userId 하드코딩
        Long userId = 1L;

        BalanceCheckResponse response = financeValidationService.checkBalance(
                userId,
                request
        );
        return ResponseEntity.ok(response);
    }

    /*핀 정보 일치 체크*/
    @PostMapping("/pin/validate")
    public ResponseEntity<PinValidateResponse> checkPin(
            @RequestHeader(value = "accesstoken", required = false) String accessToken,
            @Valid @RequestBody PinValidateRequest request
    ){

        //FIXME userId 하드코딩
        Long userId = 1L;
        PinValidateResponse response = financeValidationService.checkPin(
                userId,
                request
        );

        return ResponseEntity.ok(response);
    }

    @PostMapping(("/external-accounts/validate"))
    public ResponseEntity<ExAccValidateResponse> checkExternAccount(
            @RequestHeader(value = "accesstoken", required = false) String accessToken,
            @Valid @RequestBody ExAccValidateRequest request
    ){
        /*외부 계좌 존재 여부 체크
           worldbank와 연결*/

        ExAccValidateResponse response = financeValidationService.checkExternAccount(request);
        return ResponseEntity.ok(response);
    }
}
