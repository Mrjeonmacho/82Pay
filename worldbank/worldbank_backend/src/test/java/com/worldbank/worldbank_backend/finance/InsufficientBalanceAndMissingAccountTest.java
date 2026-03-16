package com.worldbank.worldbank_backend.finance;

import com.worldbank.worldbank_backend.finance.domain.dto.Transfer.TransferRequestDto;
import com.worldbank.worldbank_backend.finance.domain.entity.kr.BankKR;
import com.worldbank.worldbank_backend.finance.domain.repository.jp.BankJPRepository;
import com.worldbank.worldbank_backend.finance.domain.repository.kr.BankKRRepository;
import com.worldbank.worldbank_backend.finance.domain.service.TransferService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.math.BigDecimal;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.junit.jupiter.api.Assertions.assertEquals;

@SpringBootTest
public class InsufficientBalanceAndMissingAccountTest {

    @Autowired
    private TransferService transferService;

    @Autowired
    private BankKRRepository krRepository;

    @Autowired
    private BankJPRepository jpRepository;

    @Test
    @DisplayName("시나리오 1: 출금 계좌의 잔액이 부족할 때, 전체 트랜잭션이 시작도 전에 거절되고 잔액이 유지되는지 확인")
    void insufficientBalanceRollbackTest() {
        // 1. 초기 잔액 조회
        BigDecimal initialKrAmount = krRepository.findByAccountNumberNoLock("KR-1001-0001")
                .map(BankKR::getAmount).orElse(BigDecimal.ZERO);

        // 2. 잔액보다 훨씬 큰 금액(5억) 이체 요청
        TransferRequestDto request = TransferRequestDto.builder()
                .senderAccountNumber("KR-1001-0001")
                .senderBankcode("KR")
                .targetAccountNumber("JP-2001-0001")
                .targetBankcode("JP")
                .senderAmount(new BigDecimal("500000000.00")) // 5억
                .targetAmount(new BigDecimal("50000.00"))
                .build();

        // 3. 실행 및 에러 확인 (RuntimeException: 잔액 부족 발생 예상)
        assertThatThrownBy(() -> transferService.transfer(request))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("잔액 부족");

        // 4. 최종 잔액 확인: 변화가 없어야 함
        BigDecimal finalKrAmount = krRepository.findByAccountNumberNoLock("KR-1001-0001")
                .map(BankKR::getAmount).orElse(BigDecimal.ZERO);

        assertEquals(initialKrAmount, finalKrAmount, "잔액 부족 시 출금 계좌의 잔액은 변하지 않아야 합니다.");
    }

    @Test
    @DisplayName("시나리오 2: 입금 계좌가 존재하지 않을 때, 출금되었던 돈이 다시 롤백되어 원복되는지 확인 (분산 트랜잭션 핵심)")
    void missingTargetAccountRollbackTest() {
        // 1. 초기 잔액 조회
        BigDecimal initialKrAmount = krRepository.findByAccountNumberNoLock("KR-1001-0001")
                .map(BankKR::getAmount).orElse(BigDecimal.ZERO);

        // 2. 존재하지 않는 일본 계좌로의 이체 요청
        TransferRequestDto request = TransferRequestDto.builder()
                .senderAccountNumber("KR-1001-0001")
                .senderBankcode("KR")
                .targetAccountNumber("NON-EXISTENT-ACCOUNT-999") // 존재하지 않는 계좌
                .targetBankcode("JP")
                .senderAmount(new BigDecimal("1000.00"))
                .targetAmount(new BigDecimal("10.00"))
                .build();

        // 3. 실행 및 에러 확인 (RuntimeException: 일본 은행 계좌 없음 발생 예상)
        assertThatThrownBy(() -> transferService.transfer(request))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("계좌 없음");

        // 4. 최종 잔액 확인: 한국 DB에서 돈이 빠져나갔다가 다시 돌아왔는지 확인
        BigDecimal finalKrAmount = krRepository.findByAccountNumberNoLock("KR-1001-0001")
                .map(BankKR::getAmount).orElse(BigDecimal.ZERO);

        assertEquals(initialKrAmount, finalKrAmount, "입금 계좌가 없으면 출금되었던 금액도 다시 롤백되어야 합니다.");
    }
}
