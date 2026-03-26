package com.worldbank.worldbank_backend.user.strategy;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Optional;
import java.util.Random;
import java.util.UUID;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

import com.worldbank.worldbank_backend.finance.domain.entity.us.AccountHistoryUS;
import com.worldbank.worldbank_backend.finance.domain.entity.us.BankUS;
import com.worldbank.worldbank_backend.finance.domain.repository.us.AccountHistoryUSRepository;
import com.worldbank.worldbank_backend.finance.domain.repository.us.BankUSRepository;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import com.worldbank.worldbank_backend.finance.domain.service.BusinessService;
import com.worldbank.worldbank_backend.user.dto.request.SignupRequest;
import com.worldbank.worldbank_backend.user.entity.UserStatus;
import com.worldbank.worldbank_backend.user.entity.us.UserBankUS;
import com.worldbank.worldbank_backend.user.repository.us.UserBankUSRepository;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class USUserStrategy implements UserStrategy {

    private final UserBankUSRepository userRepository;
    private final BusinessService businessService;
    private final BankUSRepository bankRepository;
    private final AccountHistoryUSRepository historyRepository;

    @Override
    public String getCountryCode() {
        return "US";
    }

    @Override
    public boolean existsByEmail(String email) {
        return userRepository.existsByEmail(email);
    }

    @Override
    public Optional<UserBankUS> findByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    @Override
    @Transactional
    public void signup(SignupRequest request, String encodedPassword) {
        // 1. 미국 유저 엔티티 생성 및 저장
        UserBankUS user = UserBankUS.builder()
                .email(request.getEmail())
                .password(encodedPassword)
                .currency("USD")
                .build();
        userRepository.save(user);

        // 계좌 등록 로직 추가
        //String AccountNumber = "US-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();

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

        BankUS bank = BankUS.builder()
                .user(user)
                .userName(request.getName())
                .accountNumber(AccountNumber)
                .amount(new BigDecimal("1000"))
                .bankCode("US")
                .bankName(request.getBankName())
                .accountPassword(request.getAccountPassword())
                .build();
        bankRepository.save(bank);

        AccountHistoryUS historyUS = AccountHistoryUS.builder()
                .bankId(bank.getBankId())
                .userId(user.getUserId())
                .category(AccountHistoryUS.Category.INPUT)
                .amount(new BigDecimal("1000"))
                .otherAccountName("World bank의 축하금")
                .build();
        historyRepository.save(historyUS);
    }

}
