package com.worldbank.worldbank_backend.finance.domain.strategy;

import com.worldbank.worldbank_backend.finance.domain.dto.Check.CheckResponseDto;
import com.worldbank.worldbank_backend.finance.domain.dto.History.HistoryResponseDto;
import com.worldbank.worldbank_backend.finance.domain.dto.Info.InfoResponseDto;
import com.worldbank.worldbank_backend.finance.domain.dto.Link.LinkResponseDto;
import com.worldbank.worldbank_backend.finance.domain.dto.Transfer.TransferRequestDto;
import com.worldbank.worldbank_backend.finance.domain.entity.us.AccountHistoryUS;
import com.worldbank.worldbank_backend.finance.domain.entity.us.BankUS;
import com.worldbank.worldbank_backend.finance.domain.repository.us.AccountHistoryUSRepository;
import com.worldbank.worldbank_backend.finance.domain.repository.us.BankUSRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class BankUSStrategy implements BankStrategy {

        private final BankUSRepository bankRepository;
        private final AccountHistoryUSRepository historyRepository;

        @Override
        public String getBankCurrency() {
                return "USD";
        }

        @Override
        public CheckResponseDto checkAccount(String accountNumber) {
                return bankRepository.findByAccountNumber(accountNumber)
                                .map(account -> CheckResponseDto.builder()
                                                .message("계좌 조회가 성공했습니다.")
                                                .amount(account.getAmount())
                                                .currency(getBankCurrency())
                                                .check(true)
                                                .build())
                                .orElse(CheckResponseDto.builder()
                                                .message("존재하지 않는 계좌입니다.")
                                                .amount(null)
                                                .currency(null)
                                                .check(false)
                                                .build());
        }

        @Override
        public CheckResponseDto getAmountByUserId(Long userId) {
                return bankRepository.findByUser_UserId(userId)
                                .map(account -> CheckResponseDto.builder()
                                                .message("사용자 계좌 조회가 성공했습니다.")
                                                .amount(account.getAmount())
                                                .currency(getBankCurrency())
                                                .check(true)
                                                .build())
                                .orElse(CheckResponseDto.builder()
                                                .message("존재하지 않는 사용자 계좌입니다.")
                                                .amount(null)
                                                .currency(null)
                                                .check(false)
                                                .build());
        }

        @Override
        public void withdraw(TransferRequestDto request) {
                BankUS account = bankRepository
                                .findByAccountNumber(request.getSenderAccountNumber())
                                .orElseThrow(() -> new RuntimeException("미국 은행 계좌 없음"));

                account.withdraw(request.getSenderAmount());

                AccountHistoryUS history = AccountHistoryUS.builder()
                                .bankId(account.getBankId())
                                .userId(account.getUser().getUserId())
                                .category(AccountHistoryUS.Category.OUTPUT)
                                .amount(request.getSenderAmount())
                                .otherAccountNumber(request.getTargetAccountNumber())
                                .otherAccountName(request.getTargetAccountName())
                                .otherBankCode(request.getTargetBankcode())
                                .build();

                historyRepository.save(history);
        }

        @Override
        public LinkResponseDto linkAccount(String accountNumber, String password) {
                return bankRepository.findByAccountNumber(accountNumber)
                                .map(account -> {
                                        // DB의 비밀번호와 입력받은 비밀번호 비교
                                        if (account.getAccountPassword().equals(password)) {
                                                return LinkResponseDto.builder()
                                                                .message("계좌 연결에 성공했습니다.")
                                                                .check(true)
                                                                .build();
                                        } else {
                                                return LinkResponseDto.builder()
                                                                .message("비밀번호가 일치하지 않습니다.")
                                                                .check(false)
                                                                .build();
                                        }
                                })
                                .orElse(LinkResponseDto.builder()
                                                .message("존재하지 않는 계좌입니다.")
                                                .check(false)
                                                .build());
        }

        @Override
        public void deposit(TransferRequestDto request) {
                BankUS account = bankRepository
                                .findByAccountNumber(request.getTargetAccountNumber())
                                .orElseThrow(() -> new RuntimeException("미국 은행 계좌 없음"));

                account.deposit(request.getTargetAmount());

                AccountHistoryUS history = AccountHistoryUS.builder()
                                .bankId(account.getBankId())
                                .userId(account.getUser().getUserId())
                                .category(AccountHistoryUS.Category.INPUT)
                                .amount(request.getTargetAmount())
                                .otherAccountNumber(request.getSenderAccountNumber())
                                .otherAccountName(request.getSenderAccountName())
                                .otherBankCode(request.getSenderBankcode())
                                .build();

                historyRepository.save(history);
        }

        @Override
        public List<HistoryResponseDto> getHistoryByUserId(Long userId) {
                return historyRepository.findByUserIdOrderByCreatedAtDesc(userId).stream()
                                .map(history -> HistoryResponseDto.builder()
                                                .historyId(history.getHistoryId())
                                                .category(history.getCategory().name())
                                                .amount(history.getAmount())
                                                .otherAccountNumber(history.getOtherAccountNumber())
                                                .otherAccountName(history.getOtherAccountName())
                                                .otherBankCode(history.getOtherBankCode())
                                                .createdAt(history.getCreatedAt())
                                                .build())
                                .collect(Collectors.toList());
        }

        @Override
        public InfoResponseDto getInfoByUserId(Long userId) {
                return bankRepository.findByUser_UserId(userId)
                                .map(bank -> InfoResponseDto.builder()
                                                .userName(bank.getUserName())
                                                .accountNumber(bank.getAccountNumber())
                                                .amount(bank.getAmount())
                                                .bankName(bank.getBankName())
                                                .currency(getBankCurrency())
                                                .build())
                                .orElseThrow(() -> new RuntimeException("해당 유저의 계좌 정보를 찾을 수 없습니다."));
        }
}
