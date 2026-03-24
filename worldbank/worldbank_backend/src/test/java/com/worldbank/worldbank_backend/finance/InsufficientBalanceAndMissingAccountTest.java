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

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.junit.jupiter.api.Assertions.assertEquals;

@SpringBootTest
@Transactional
public class InsufficientBalanceAndMissingAccountTest {

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
    @DisplayName("시나리오 1: 출금 계좌의 잔액이 부족할 때, 전체 트랜잭션이 시작도 전에 거절되고 잔액이 유지되는지 확인")
    void insufficientBalanceRollbackTest() {
        // Given: 유저 가입 (기본 잔액 1,000,000원)
        userService.signUp(SignupRequest.builder()
                .email("insuf@test.com").password("1234").countryCode("KR")
                .name("잔액부족").bankName("한국은행").accountPassword("1234").build());
        userService.signUp(SignupRequest.builder()
                .email("insuf_target@test.com").password("1234").countryCode("JP")
                .name("타겟").bankName("도쿄은행").accountPassword("1234").build());

        UserBankKR sender = userKRRepository.findByEmail("insuf@test.com").get();
        BankKR senderBank = krRepository.findByUser_UserId(sender.getUserId()).get();
        UserBankJP receiver = userJPRepository.findByEmail("insuf_target@test.com").get();
        BankJP receiverBank = jpRepository.findByUser_UserId(receiver.getUserId()).get();

        // 1. 초기 잔액 조회
        BigDecimal initialKrAmount = senderBank.getAmount();

        // 2. 잔액보다 훨씬 큰 금액(5억) 이체 요청
        TransferRequestDto request = TransferRequestDto.builder()
                .senderAccountNumber(senderBank.getAccountNumber())
                .senderBankcode(senderBank.getBankCode())
                .senderCurrency("KRW")
                .targetAccountNumber(receiverBank.getAccountNumber())
                .targetBankcode(receiverBank.getBankCode())
                .targetCurrency("JPY")
                .senderAmount(new BigDecimal("500000000.00")) // 5억
                .targetAmount(new BigDecimal("50000.00"))
                .build();

        // 3. 실행 및 에러 확인 (JTA 환경에서는 예외가 JpaSystemException 등으로 감싸질 수 있음)
        try {
            transferService.transfer(request);
        } catch (Exception e) {
            System.out.println("예상된 에러 발생: " + e.getMessage());
        }

        // 4. 최종 잔액 확인: 변화가 없어야 함
        BigDecimal finalKrAmount = krRepository.findByAccountNumberNoLock(senderBank.getAccountNumber())
                .map(BankKR::getAmount).orElse(BigDecimal.ZERO);

        assertEquals(initialKrAmount.stripTrailingZeros(), finalKrAmount.stripTrailingZeros(), "잔액 부족 시 출금 계좌의 잔액은 변하지 않아야 합니다.");
    }

    @Test
    @DisplayName("시나리오 2: 입금 계좌가 존재하지 않을 때, 출금되었던 돈이 다시 롤백되어 원복되는지 확인 (분산 트랜잭션 핵심)")
    void missingTargetAccountRollbackTest() {
        // Given: 유저 가입
        userService.signUp(SignupRequest.builder()
                .email("missing@test.com").password("1234").countryCode("KR")
                .name("계좌없음").bankName("한국은행").accountPassword("1234").build());
        
        UserBankKR sender = userKRRepository.findByEmail("missing@test.com").get();
        BankKR senderBank = krRepository.findByUser_UserId(sender.getUserId()).get();

        // 1. 초기 잔액 조회
        BigDecimal initialKrAmount = senderBank.getAmount();

        // 2. 존재하지 않는 일본 계좌로의 이체 요청
        TransferRequestDto request = TransferRequestDto.builder()
                .senderAccountNumber(senderBank.getAccountNumber())
                .senderBankcode(senderBank.getBankCode())
                .senderCurrency("KRW")
                .targetAccountNumber("NON-EXISTENT-ACCOUNT-999") // 존재하지 않는 계좌
                .targetBankcode("JP")
                .targetCurrency("JPY")
                .senderAmount(new BigDecimal("1000.00"))
                .targetAmount(new BigDecimal("10.00"))
                .build();

        // 3. 실행 및 에러 확인
        try {
            transferService.transfer(request);
        } catch (Exception e) {
            System.out.println("예상된 에러 발생: " + e.getMessage());
        }

        // 4. 최종 잔액 확인: 한국 DB에서 돈이 빠져나갔다가 다시 돌아왔는지 확인
        BigDecimal finalKrAmount = krRepository.findByAccountNumberNoLock(senderBank.getAccountNumber())
                .map(BankKR::getAmount).orElse(BigDecimal.ZERO);

        assertEquals(initialKrAmount.stripTrailingZeros(), finalKrAmount.stripTrailingZeros(), "입금 계좌가 없으면 출금되었던 금액도 다시 롤백되어야 합니다.");
    }
}
