package com.palipay.palipay_backend.finance.controller;

import com.palipay.palipay_backend.finance.dto.request.FinanceAccountRequest;
import com.palipay.palipay_backend.finance.dto.response.FinanceAccountResponse;
import com.palipay.palipay_backend.finance.service.FinanceAccountService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/useraccount")
@RequiredArgsConstructor
public class FinanceAccountController {
    private final FinanceAccountService financeAccountService;

    @PostMapping("/accounts")
    public ResponseEntity<FinanceAccountResponse> transfer(
            @RequestHeader(value = "accesstoken", required = false) String accessToken,
            @Valid @RequestBody FinanceAccountRequest request
    ) {

        //FIXME
        Long userId = 1L;

        FinanceAccountResponse response = financeAccountService.connectWallet(
                userId,
                request
        );

        return ResponseEntity.ok(response);
    }


}
