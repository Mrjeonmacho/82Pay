package com.worldbank.worldbank_backend.finance.domain.controller;

import com.worldbank.worldbank_backend.finance.domain.dto.TransferRequestDto;
import com.worldbank.worldbank_backend.finance.domain.dto.TransferResponseDto;
import com.worldbank.worldbank_backend.finance.domain.service.TransferService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/finance")
@RequiredArgsConstructor
public class Controller {

    private final TransferService transferService;

    @PatchMapping
    public TransferResponseDto transfer(@RequestBody TransferRequestDto request) {
        return transferService.transfer(request);
    }
}