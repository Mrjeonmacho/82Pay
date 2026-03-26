package com.worldbank.worldbank_backend.user.strategy;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Optional;
import java.util.Random;
import java.util.UUID;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

import com.worldbank.worldbank_backend.finance.domain.entity.ch.AccountHistoryCH;
import com.worldbank.worldbank_backend.finance.domain.entity.ch.BankCH;
import com.worldbank.worldbank_backend.finance.domain.repository.ch.AccountHistoryCHRepository;
import com.worldbank.worldbank_backend.finance.domain.repository.ch.BankCHRepository;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import com.worldbank.worldbank_backend.finance.domain.service.BusinessService;
import com.worldbank.worldbank_backend.user.dto.request.SignupRequest;
import com.worldbank.worldbank_backend.user.entity.UserStatus;
import com.worldbank.worldbank_backend.user.entity.ch.UserBankCH;
import com.worldbank.worldbank_backend.user.repository.ch.UserBankCHRepository;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class CHUserStrategy implements UserStrategy {

    private final UserBankCHRepository userRepository;
    private final BusinessService businessService;
    private final BankCHRepository bankRepository;
    private final AccountHistoryCHRepository historyRepository;

    @Override
    public String getCountryCode() {
        return "CH";
    }

    @Override
    public boolean existsByEmail(String email) {
        return userRepository.existsByEmail(email);
    }

    @Override
    public Optional<UserBankCH> findByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    @Override
    @Transactional
    public void signup(SignupRequest request, String encodedPassword) {
        // 1. 중국 유저 엔티티 생성 및 저장
        UserBankCH user = UserBankCH.builder()
                .email(request.getEmail())
                .password(encodedPassword)
                .currency("CNY")
                .build();
        userRepository.save(user);


        // 계좌 등록 로직 추가
        //String AccountNumber = "CH-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();

        String AccountNumber;
        Random random = new Random();

        while (true) {
            // 숫자4자리-숫자4자리-숫자4자리 생성
            AccountNumber = IntStream.range(0, 12)
                    .mapToObj(i -> String.valueOf(random.nextInt(10)))
                    .collect(Collectors.joining(""));

            // DB에 해당 계좌번호가 있는지 확인
            if (!bankRepository.existsByAccountNumber(AccountNumber)) {
                break; // 중복이 없으면 루프 탈출
            }
        }

        BankCH bank = BankCH.builder()
                .user(user)
                .userName(request.getName())
                .accountNumber(AccountNumber)
                .amount(new BigDecimal("5000"))
                .bankCode("CH")
                .bankName(request.getBankName())
                .accountPassword(request.getAccountPassword())
                .build();
        bankRepository.save(bank);

        AccountHistoryCH historyCH = AccountHistoryCH.builder()
                .bankId(bank.getBankId())
                .userId(user.getUserId())
                .category(AccountHistoryCH.Category.INPUT)
                .amount(new BigDecimal("5000"))
                .otherAccountName("World bank의 축하금")
                .build();
        historyRepository.save(historyCH);

    }

}
