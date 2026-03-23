package com.palipay.palipay_backend.finance.controller;

import com.palipay.palipay_backend.finance.dto.request.FinanceAccountRequest;
import com.palipay.palipay_backend.finance.dto.request.WalletPinRequest;
import com.palipay.palipay_backend.finance.dto.request.WalletPinUpdateRequest;
import com.palipay.palipay_backend.finance.dto.response.FinanceAccountResponse;
import com.palipay.palipay_backend.finance.dto.response.WalletPinResponse;
import com.palipay.palipay_backend.finance.service.FinanceAccountService;
import com.palipay.palipay_backend.global.security.JwtProvider;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/wallet")
@RequiredArgsConstructor
public class FinanceAccountController {
    private final FinanceAccountService financeAccountService;

    private final JwtProvider jwtProvider;

    @PostMapping("/accounts")
    public ResponseEntity<FinanceAccountResponse> connectAccount(
            @RequestHeader(value = "accesstoken", required = false) String accessToken,
            @Valid @RequestBody FinanceAccountRequest request
    ) {

        Long userId = jwtProvider.getUserId(accessToken);

        FinanceAccountResponse response = financeAccountService.connectWallet(
                userId,
                request
        );

        return ResponseEntity.ok(response);
    }

    @PostMapping("/pin")
    public ResponseEntity<WalletPinResponse> createPin(
            @RequestHeader(value = "accesstoken", required = false) String accessToken,
            @Valid @RequestBody WalletPinRequest request
    ){
        Long userId = jwtProvider.getUserId(accessToken);

        WalletPinResponse response = financeAccountService.createPin(
                userId,
                request
        );

        return ResponseEntity.ok(response);
    }

    @PatchMapping("/pin")
    public ResponseEntity<WalletPinResponse> createPin(
            @RequestHeader(value = "accesstoken", required = false) String accessToken,
            @Valid @RequestBody WalletPinUpdateRequest request
    ){
        Long userId = jwtProvider.getUserId(accessToken);

        WalletPinResponse response = financeAccountService.updatePin(
                userId,
                request
        );

        return ResponseEntity.ok(response);
    }



}
