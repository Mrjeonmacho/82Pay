package com.worldbank.worldbank_backend.user.strategy;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Optional;
import java.util.Random;
import java.util.UUID;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

import com.worldbank.worldbank_backend.finance.domain.entity.kr.AccountHistoryKR;
import com.worldbank.worldbank_backend.finance.domain.entity.kr.BankKR;
import com.worldbank.worldbank_backend.finance.domain.repository.ch.AccountHistoryCHRepository;
import com.worldbank.worldbank_backend.finance.domain.repository.ch.BankCHRepository;
import com.worldbank.worldbank_backend.finance.domain.repository.kr.AccountHistoryKRRepository;
import com.worldbank.worldbank_backend.finance.domain.repository.kr.BankKRRepository;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import com.worldbank.worldbank_backend.finance.domain.service.BusinessService;
import com.worldbank.worldbank_backend.user.dto.request.SignupRequest;
import com.worldbank.worldbank_backend.user.entity.UserStatus;
import com.worldbank.worldbank_backend.user.entity.kr.UserBankKR;
import com.worldbank.worldbank_backend.user.repository.kr.UserBankKRRepository;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class KrUserStrategy implements UserStrategy {

    private final UserBankKRRepository userRepository;
    private final BusinessService businessService;
    private final BankKRRepository bankRepository;
    private final AccountHistoryKRRepository historyRepository;

    @Override
    public String getCountryCode() {
        return "KR";
    }

    @Override
    public boolean existsByEmail(String email) {
        return userRepository.existsByEmail(email);
    }

    @Override
    public Optional<UserBankKR> findByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    @Override
    @Transactional
    public void signup(SignupRequest request, String encodedPassword) {
        // 1. 한국 유저 엔티티 생성 및 저장
        UserBankKR user = UserBankKR.builder()
                .email(request.getEmail())
                .password(encodedPassword)
                .currency("KRW")
                .build();
        userRepository.save(user);

        // 계좌 등록 로직 추가
        //String AccountNumber = "KR-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();

        String AccountNumber;
        Random random = new Random();

        while (true) {
            // 숫자4자리-숫자4자리-숫자4자리 생성
            AccountNumber = IntStream.range(0, 3)
                    .mapToObj(i -> String.format("%04d", random.nextInt(10000)))
                    .collect(Collectors.joining("-"));

            // DB에 해당 계좌번호가 있는지 확인
            if (!bankRepository.existsByAccountNumber(AccountNumber)) {
                break; // 중복이 없으면 루프 탈출
            }
        }

        BankKR bank = BankKR.builder()
                .user(user)
                .userName(request.getName())
                .accountNumber(AccountNumber)
                .amount(new BigDecimal("1000000"))
                .bankCode("KR")
                .bankName(request.getBankName())
                .accountPassword(request.getAccountPassword())
                .build();
        bankRepository.save(bank);

        AccountHistoryKR historyKR = AccountHistoryKR.builder()
                .bankId(bank.getBankId())
                .userId(user.getUserId())
                .category(AccountHistoryKR.Category.INPUT)
                .amount(new BigDecimal("1000000"))
                .otherAccountName("World bank의 축하금")
                .build();
        historyRepository.save(historyKR);
    }
}