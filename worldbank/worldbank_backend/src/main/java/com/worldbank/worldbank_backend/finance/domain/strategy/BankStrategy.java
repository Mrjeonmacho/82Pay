package com.worldbank.worldbank_backend.finance.domain.strategy;

import com.worldbank.worldbank_backend.finance.domain.dto.Check.CheckResponseDto;
import com.worldbank.worldbank_backend.finance.domain.dto.Link.LinkResponseDto;
import com.worldbank.worldbank_backend.finance.domain.dto.Transfer.TransferRequestDto;

public interface BankStrategy {

    String getBankCurrency();


    void withdraw(TransferRequestDto request);

    void deposit(TransferRequestDto request);

    CheckResponseDto checkAccount(String accountNumber);

    LinkResponseDto linkAccount(String accountNumber, String password);
}