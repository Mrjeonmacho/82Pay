package com.palipay.palipay_backend.external.controller;

import com.palipay.palipay_backend.external.dto.response.ExchangeQuoteResponse;
import com.palipay.palipay_backend.external.service.ExchangeRateRedisService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/finance")
@RequiredArgsConstructor
public class ExFxController {
    private final ExchangeRateRedisService exchangeRateRedisService;

    @GetMapping("/quote")
    public ResponseEntity<ExchangeQuoteResponse> createExchangeQuote(
            @RequestHeader(value = "accesstoken", required = false) String accessToken,
            @RequestParam("currency") String currency
    ) {
        ExchangeQuoteResponse response = exchangeRateRedisService.createExchangeQuote(currency);
        return ResponseEntity.ok(response);
    }
}
