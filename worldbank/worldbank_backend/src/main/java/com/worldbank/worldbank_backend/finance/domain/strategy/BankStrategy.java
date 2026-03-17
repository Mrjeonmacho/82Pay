package com.worldbank.worldbank_backend.finance.domain.strategy;

import com.worldbank.worldbank_backend.finance.domain.dto.Transfer.TransferRequestDto;

public interface BankStrategy {

    String getBankCurrency();


    void withdraw(TransferRequestDto request);

    void deposit(TransferRequestDto request);
}