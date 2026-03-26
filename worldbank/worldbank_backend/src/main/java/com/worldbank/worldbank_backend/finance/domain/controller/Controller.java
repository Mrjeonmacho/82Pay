package com.worldbank.worldbank_backend.finance.domain.controller;

import com.worldbank.worldbank_backend.finance.domain.dto.Business.BusinessResponseDto;
import com.worldbank.worldbank_backend.finance.domain.dto.Check.CheckRequestDto;
import com.worldbank.worldbank_backend.finance.domain.dto.Check.CheckResponseDto;
import com.worldbank.worldbank_backend.finance.domain.dto.History.HistoryResponseDto;
import com.worldbank.worldbank_backend.finance.domain.dto.Info.InfoResponseDto;
import com.worldbank.worldbank_backend.finance.domain.dto.Link.LinkRequestDto;
import com.worldbank.worldbank_backend.finance.domain.dto.Link.LinkResponseDto;
import com.worldbank.worldbank_backend.finance.domain.dto.Transfer.TransferRequestDto;
import com.worldbank.worldbank_backend.finance.domain.dto.Transfer.TransferResponseDto;
import com.worldbank.worldbank_backend.finance.domain.service.BusinessService;
import com.worldbank.worldbank_backend.finance.domain.service.CheckService;
import com.worldbank.worldbank_backend.finance.domain.service.TransferService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/finance")
@RequiredArgsConstructor
public class Controller {

    private final TransferService transferService;
    private final BusinessService businessService;
    private final CheckService checkService;

    @PatchMapping
    public TransferResponseDto transfer(@RequestBody TransferRequestDto request) {
        return transferService.transfer(request);
    }

    @GetMapping("/corporation/{accountNumber}")
    public BusinessResponseDto getCorporation(@PathVariable String accountNumber) {
        return businessService.getBusinessInfo(accountNumber);
    }

    @GetMapping("/check")
    public CheckResponseDto checkAccount(@RequestParam String targetAccountNumber,
            @RequestParam(required = false) String targetAccountName,
            @RequestParam(required = false) String targetBankCode,
            @RequestParam String targetCurrency) {

        CheckRequestDto request = CheckRequestDto.builder()
                .targetAccountNumber(targetAccountNumber)
                .targetAccountName(targetAccountName)
                .targetBankCode(targetBankCode)
                .targetCurrency(targetCurrency)
                .build();
        return checkService.checkAccount(request);
    }

    @PostMapping("/Link")
    public LinkResponseDto linkAccount(@RequestBody LinkRequestDto request) {
        return checkService.linkAccount(request);
    }

    @GetMapping("/user/{userid}")
    public CheckResponseDto getAmountByUserId(
            @PathVariable("userid") Long userId,
            @RequestParam("currency") String currency) {
        return checkService.getAmountByUserId(userId, currency);
    }

    @GetMapping("/history/{userid}")
    public List<HistoryResponseDto> getHistory(
            @PathVariable("userid") Long userId,
            @RequestParam("currency") String currency) {
        return checkService.getHistory(userId, currency);
    }

    @GetMapping("/info/{userid}")
    public InfoResponseDto getInfo(
            @PathVariable("userid") Long userId,
            @RequestParam("currency") String currency) {
        return checkService.getInfo(userId, currency);
    }

}
