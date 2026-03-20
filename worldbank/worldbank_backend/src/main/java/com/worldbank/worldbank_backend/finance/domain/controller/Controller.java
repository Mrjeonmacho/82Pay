package com.worldbank.worldbank_backend.finance.domain.controller;

import com.worldbank.worldbank_backend.finance.domain.dto.Business.BusinessResponseDto;
import com.worldbank.worldbank_backend.finance.domain.dto.Check.CheckRequestDto;
import com.worldbank.worldbank_backend.finance.domain.dto.Check.CheckResponseDto;
import com.worldbank.worldbank_backend.finance.domain.dto.Transfer.TransferRequestDto;
import com.worldbank.worldbank_backend.finance.domain.dto.Transfer.TransferResponseDto;
import com.worldbank.worldbank_backend.finance.domain.service.BusinessService;
import com.worldbank.worldbank_backend.finance.domain.service.CheckService;
import com.worldbank.worldbank_backend.finance.domain.service.TransferService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

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
    public CheckResponseDto checkAccount(@ModelAttribute CheckRequestDto request) {
        return checkService.checkAccount(request);
    }
}
