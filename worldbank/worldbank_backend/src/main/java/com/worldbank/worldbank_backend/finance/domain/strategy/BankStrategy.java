package com.worldbank.worldbank_backend.finance.domain.strategy;

import com.worldbank.worldbank_backend.finance.domain.dto.TransferRequestDto;

public interface BankStrategy {

    String getBankCode();


    void withdraw(TransferRequestDto request);

    void deposit(TransferRequestDto request);
}