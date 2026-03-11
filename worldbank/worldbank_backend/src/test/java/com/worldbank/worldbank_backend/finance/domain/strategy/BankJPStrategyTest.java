package com.worldbank.worldbank_backend.finance.domain.strategy;

import com.worldbank.worldbank_backend.finance.domain.dto.TransferRequestDto;
import com.worldbank.worldbank_backend.finance.domain.entity.AccountHistoryJP;
import com.worldbank.worldbank_backend.finance.domain.entity.BankJP;
import com.worldbank.worldbank_backend.finance.domain.enums.JPBankCode;
import com.worldbank.worldbank_backend.finance.domain.repository.AccountHistoryJPRepository;
import com.worldbank.worldbank_backend.finance.domain.repository.BankJPRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@Transactional
class BankJPStrategyTest {

    @Autowired
    private BankJPStrategy bankJPStrategy;

    @Autowired
    private BankJPRepository bankRepository;

    @Autowired
    private AccountHistoryJPRepository historyRepository;

    private final String SENDER_ACCOUNT = "123-456-789";
    private final String TARGET_ACCOUNT = "987-654-321";

    @BeforeEach
    void setUp() {
        // 발신자 계좌 생성 (잔액 10,000엔)
        BankJP sender = BankJP.builder()
                .userId(1L)
                .userName("Sender")
                .accountNumber(SENDER_ACCOUNT)
                .amount(new BigDecimal("10000"))
                .bankCode(JPBankCode.JPPSJPJ1)
                .build();

        // 수신자 계좌 생성 (잔액 5,000엔)
        BankJP target = BankJP.builder()
                .userId(2L)
                .userName("Target")
                .accountNumber(TARGET_ACCOUNT)
                .amount(new BigDecimal("5000"))
                .bankCode(JPBankCode.JPPSJPJ1)
                .build();

        bankRepository.saveAll(List.of(sender, target));
    }

    @Test
    @DisplayName("출금 테스트: 계좌 잔액이 차감되고 출금 내역이 생성되어야 한다")
    void withdrawTest() {
        // Given
        BigDecimal withdrawAmount = new BigDecimal("2000");
        TransferRequestDto request = TransferRequestDto.builder()
                .senderAccountNumber(SENDER_ACCOUNT)
                .targetAccountNumber(TARGET_ACCOUNT)
                .targetAccountName("Target")
                .targetBankcode("JP")
                .senderAmount(withdrawAmount)
                .build();

        // When
        bankJPStrategy.withdraw(request);

        // Then
        // 1. 잔액 확인 (10000 - 2000 = 8000)
        BankJP updatedSender = bankRepository.findByAccountNumber(SENDER_ACCOUNT).orElseThrow();
        assertThat(updatedSender.getAmount().compareTo(new BigDecimal("8000"))).isEqualTo(0);

        // 2. 히스토리 확인
        List<AccountHistoryJP> histories = historyRepository.findAll();
        assertThat(histories).hasSize(1);
        AccountHistoryJP history = histories.get(0);
        assertThat(history.getCategory()).isEqualTo(AccountHistoryJP.Category.OUTPUT);
        assertThat(history.getAmount().compareTo(withdrawAmount)).isEqualTo(0);
        assertThat(history.getOtherAccountNumber()).isEqualTo(TARGET_ACCOUNT);
    }

    @Test
    @DisplayName("입금 테스트: 계좌 잔액이 증가하고 입금 내역이 생성되어야 한다")
    void depositTest() {
        // Given
        BigDecimal depositAmount = new BigDecimal("3000");
        TransferRequestDto request = TransferRequestDto.builder()
                .senderAccountNumber(SENDER_ACCOUNT)
                .senderAccountName("Sender")
                .senderBankcode("JP")
                .targetAccountNumber(TARGET_ACCOUNT)
                .targetAccountName("Target")
                .targetBankcode("JP")
                .senderAmount(depositAmount) // Strategy에서 senderAmount를 사용함
                .targetAmount(depositAmount)
                .build();

        // When
        bankJPStrategy.deposit(request);

        // Then
        // 1. 잔액 확인 (5000 + 3000 = 8000)
        BankJP updatedTarget = bankRepository.findByAccountNumber(TARGET_ACCOUNT).orElseThrow();
        assertThat(updatedTarget.getAmount().compareTo(new BigDecimal("8000"))).isEqualTo(0);

        // 2. 히스토리 확인
        List<AccountHistoryJP> histories = historyRepository.findAll();
        assertThat(histories).hasSize(1);
        AccountHistoryJP history = histories.get(0);
        
        // 주의: 현재 BankJPStrategy 로직상 Category.OUTPUT으로 고정되어 있어 테스트가 실패할 수 있음
        // 만약 로직을 수정하지 않았다면 아래 Assertion에서 실패할 것입니다.
        assertThat(history.getCategory()).isEqualTo(AccountHistoryJP.Category.INPUT);
        assertThat(history.getAmount().compareTo(depositAmount)).isEqualTo(0);
    }
}
