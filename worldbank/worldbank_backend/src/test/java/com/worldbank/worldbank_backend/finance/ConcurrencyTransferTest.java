package com.worldbank.worldbank_backend.finance;

import com.worldbank.worldbank_backend.finance.domain.dto.Transfer.TransferRequestDto;
import com.worldbank.worldbank_backend.finance.domain.entity.jp.BankJP;
import com.worldbank.worldbank_backend.finance.domain.entity.kr.BankKR;
import com.worldbank.worldbank_backend.finance.domain.repository.jp.BankJPRepository;
import com.worldbank.worldbank_backend.finance.domain.repository.kr.BankKRRepository;
import com.worldbank.worldbank_backend.finance.domain.service.TransferService;
import com.worldbank.worldbank_backend.user.dto.request.SignupRequest;
import com.worldbank.worldbank_backend.user.entity.jp.UserBankJP;
import com.worldbank.worldbank_backend.user.entity.kr.UserBankKR;
import com.worldbank.worldbank_backend.user.repository.jp.UserBankJPRepository;
import com.worldbank.worldbank_backend.user.repository.kr.UserBankKRRepository;
import com.worldbank.worldbank_backend.user.service.UserService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.UUID;

@SpringBootTest
@Transactional
public class ConcurrencyTransferTest {

    @Autowired
    private TransferService transferService;

    @Autowired
    private UserService userService;

    @Autowired
    private UserBankKRRepository userKRRepository;

    @Autowired
    private BankKRRepository krRepository;

    @Autowired
    private UserBankJPRepository userJPRepository;

    @Autowired
    private BankJPRepository jpRepository;

    @Test
    @DisplayName("동시성 테스트: 100건의 동시 입금 요청이 순차적으로 잘 처리되어 갱신 유실(Lost Update)이 없는지 확인")
    void concurrentDepositTest() throws InterruptedException {
        // Given: 유저 가입 및 계좌 생성
        String senderEmail = "con_s_" + UUID.randomUUID().toString().substring(0, 5) + "@test.com";
        String receiverEmail = "con_r_" + UUID.randomUUID().toString().substring(0, 5) + "@test.com";

        userService.signUp(SignupRequest.builder()
                .email(senderEmail).password("1234").countryCode("KR")
                .name("송신").bankName("한국은행").accountPassword("1234").build());
        userService.signUp(SignupRequest.builder()
                .email(receiverEmail).password("1234").countryCode("JP")
                .name("수신").bankName("도쿄은행").accountPassword("1234").build());

        UserBankKR sender = userKRRepository.findByEmail(senderEmail).get();
        BankKR senderBank = krRepository.findByUser_UserId(sender.getUserId()).get();

        UserBankJP receiver = userJPRepository.findByEmail(receiverEmail).get();
        BankJP receiverBank = jpRepository.findByUser_UserId(receiver.getUserId()).get();

        // 1. 테스트 설정
        int threadCount = 100; // 동시에 보낼 요청 수

        BigDecimal transferAmount = new BigDecimal("10.00"); // 한 번에 보낼 금액 (10원)

        // 스레드 풀 생성
        ExecutorService executorService = Executors.newFixedThreadPool(32);
        // 모든 스레드가 작업을 마칠 때까지 기다리기 위한 래치
        CountDownLatch latch = new CountDownLatch(threadCount);

        // 2. 초기 잔액 조회 (락 없는 메서드로 조회)
        BigDecimal initialJpAmount = receiverBank.getAmount();

        // 3. 100번의 이체 요청을 동시에 실행
        for (int i = 0; i < threadCount; i++) {
            executorService.submit(() -> {
                try {
                    TransferRequestDto request = TransferRequestDto.builder()
                            .senderAccountNumber(senderBank.getAccountNumber())
                            .senderBankcode(senderBank.getBankCode())
                            .senderCurrency("KRW")
                            .targetAccountNumber(receiverBank.getAccountNumber()) // 타겟은 모두 동일한 JP 계좌
                            .targetBankcode(receiverBank.getBankCode())
                            .targetCurrency("JPY")
                            .senderAmount(transferAmount)
                            .targetAmount(transferAmount)
                            .build();

                    transferService.transfer(request);

                } catch (Exception e) {
                    System.err.println("이체 실패: " + e.getMessage());
                } finally {
                    latch.countDown();
                }
            });
        }

        // 모든 스레드의 작업이 끝날 때까지 대기
        latch.await();

        // 4. 최종 잔액 검증
        BigDecimal finalJpAmount = jpRepository.findByAccountNumberNoLock(receiverBank.getAccountNumber())
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
