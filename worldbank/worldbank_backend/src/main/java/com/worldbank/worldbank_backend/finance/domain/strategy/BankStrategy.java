package com.worldbank.worldbank_backend.finance.domain.strategy;

import com.worldbank.worldbank_backend.finance.domain.dto.Check.CheckResponseDto;
import com.worldbank.worldbank_backend.finance.domain.dto.History.HistoryResponseDto;
import com.worldbank.worldbank_backend.finance.domain.dto.Info.InfoResponseDto;
import com.worldbank.worldbank_backend.finance.domain.dto.Link.LinkResponseDto;
import com.worldbank.worldbank_backend.finance.domain.dto.Transfer.TransferRequestDto;

import java.util.List;

public interface BankStrategy {

    String getBankCurrency();


    void withdraw(TransferRequestDto request);

    void deposit(TransferRequestDto request);

    CheckResponseDto checkAccount(String accountNumber);

    CheckResponseDto getAmountByUserId(Long userId);

    LinkResponseDto linkAccount(String accountNumber, String password);

    List<HistoryResponseDto> getHistoryByUserId(Long userId);

    InfoResponseDto getInfoByUserId(Long userId);
}