package com.palipay.palipay_backend.finance.controller;


import com.palipay.palipay_backend.finance.dto.request.FinanceTransferRequest;
import com.palipay.palipay_backend.finance.dto.response.FinanceTransferResponse;
import com.palipay.palipay_backend.finance.service.FinanceTransferService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/finance/transfers")
@RequiredArgsConstructor
public class FinanceTransferController {

    private final FinanceTransferService financeTransferService;

    @PostMapping
    public ResponseEntity<FinanceTransferResponse> transfer(
            @RequestHeader(value = "accesstoken", required = false) String accessToken,
            @RequestHeader(value = "Idempotency-Key", required = false) String idempotencyKey,
            @Valid @RequestBody FinanceTransferRequest request
    ) {

        Long userId = 1L;

        FinanceTransferResponse response = financeTransferService.transfer(
                userId,
                idempotencyKey,
                request);
        return ResponseEntity.ok(response);
    }
}