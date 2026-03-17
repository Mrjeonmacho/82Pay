package com.worldbank.worldbank_backend.finance;

import com.worldbank.worldbank_backend.finance.domain.dto.Transfer.TransferRequestDto;
import com.worldbank.worldbank_backend.finance.domain.entity.jp.BankJP;
import com.worldbank.worldbank_backend.finance.domain.repository.jp.BankJPRepository;
import com.worldbank.worldbank_backend.finance.domain.service.TransferService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.math.BigDecimal;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
public class ConcurrencyTransferTest {

    @Autowired
    private TransferService transferService;

    @Autowired
    private BankJPRepository jpRepository;

    @Test
    @DisplayName("동시성 테스트: 100건의 동시 입금 요청이 순차적으로 잘 처리되어 갱신 유실(Lost Update)이 없는지 확인")
    void concurrentDepositTest() throws InterruptedException {
        // 1. 테스트 설정
        int threadCount = 100; // 동시에 보낼 요청 수
        BigDecimal transferAmount = new BigDecimal("10.00"); // 한 번에 보낼 금액 (10원)

        // 스레드 풀 생성
        ExecutorService executorService = Executors.newFixedThreadPool(32);
        // 모든 스레드가 작업을 마칠 때까지 기다리기 위한 래치
        CountDownLatch latch = new CountDownLatch(threadCount);

        // 2. 초기 잔액 조회 (락 없는 메서드로 조회)
        BigDecimal initialJpAmount = jpRepository.findByAccountNumberNoLock("JP-2001-0001")
                .map(BankJP::getAmount).orElse(BigDecimal.ZERO);

        // 3. 100번의 이체 요청을 동시에 실행
        for (int i = 0; i < threadCount; i++) {
            executorService.submit(() -> {
                try {
                    // (주의: 출금 계좌는 잔액이 넉넉해야 합니다. 임의의 넉넉한 KR 계좌 사용)
                    TransferRequestDto request = TransferRequestDto.builder()
                            .senderAccountNumber("KR-1001-0001")
                            .senderBankcode("KR")
                            .senderCurrency("KRW")
                            .targetAccountNumber("JP-2001-0001") // 타겟은 모두 동일한 JP 계좌
                            .targetBankcode("JP")
                            .targetCurrency("JPY")
                            .senderAmount(transferAmount)
                            .targetAmount(transferAmount)
                            .build();

                    transferService.transfer(request);
                } catch (Exception e) {
                    // 로그를 남기되, 에러가 발생해도 카운트를 내려서 래치가 멈추지 않게 함
                    System.err.println("이체 실패: " + e.getMessage());
                } finally {
                    latch.countDown();
                }
            });
        }

        // 모든 스레드의 작업이 끝날 때까지 대기
        latch.await();

        // 4. 최종 잔액 검증
        BigDecimal finalJpAmount = jpRepository.findByAccountNumberNoLock("JP-2001-0001")
                .map(BankJP::getAmount).orElse(BigDecimal.ZERO);

        // 예상 잔액 = 초기 잔액 + (10원 * 100번 = 1000원)
        BigDecimal expectedAmount = initialJpAmount.add(transferAmount.multiply(new BigDecimal(threadCount)));

        System.out.println("초기 잔액: " + initialJpAmount);
        System.out.println("최종 잔액: " + finalJpAmount);
        System.out.println("예상 잔액: " + expectedAmount);

        // 락이 제대로 작동했다면 예상 잔액과 실제 잔액이 정확히 일치해야 함
        assertThat(finalJpAmount.compareTo(expectedAmount)).isEqualTo(0);
    }
}
