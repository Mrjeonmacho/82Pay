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

import java.util.UUID;

@SpringBootTest
@Transactional
public class XARollbackTest {

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
    @DisplayName("XA 분산 트랜잭션 롤백 테스트: 출금 후 입금 전 예외 발생 시나리오")
    void xaDistributedTransactionRollbackTest() {
        // Given: 유저 가입 및 계좌 생성
        String senderEmail = "xa_s_" + UUID.randomUUID().toString().substring(0, 5) + "@test.com";
        String receiverEmail = "xa_r_" + UUID.randomUUID().toString().substring(0, 5) + "@test.com";

        userService.signUp(SignupRequest.builder()
                .email(senderEmail).password("1234").countryCode("KR")
                .name("보내는이").bankName("한국은행").accountPassword("1234").build());
        userService.signUp(SignupRequest.builder()
                .email(receiverEmail).password("1234").countryCode("JP")
                .name("받는이").bankName("도쿄은행").accountPassword("1234").build());

        UserBankKR sender = userKRRepository.findByEmail(senderEmail).get();
        BankKR senderBank = krRepository.findByUser_UserId(sender.getUserId()).get();

        UserBankJP receiver = userJPRepository.findByEmail(receiverEmail).get();
        BankJP receiverBank = jpRepository.findByUser_UserId(receiver.getUserId()).get();

        // 1. 초기 잔액 조회
        BigDecimal initialKrAmount = senderBank.getAmount();
        BigDecimal initialJpAmount = receiverBank.getAmount();

        // 2. 강제로 에러가 발생할 수밖에 없는 요청 (타겟 계좌번호를 잘못 입력)
        TransferRequestDto request = TransferRequestDto.builder()
                .senderAccountNumber(senderBank.getAccountNumber())
                .senderBankcode(senderBank.getBankCode())
                .senderCurrency("KRW")
                .targetAccountNumber("INVALID-ACCOUNT-999") // 에러 유발
                .targetBankcode(receiverBank.getBankCode())
                .targetCurrency("JPY")
                .senderAmount(new BigDecimal("1000.00"))
                .targetAmount(new BigDecimal("10.00"))
                .build();

        // 3. 실행 및 롤백 확인
        assertThatThrownBy(() -> transferService.transfer(request))
                .isInstanceOf(RuntimeException.class);

        // 4. DB 확인: 두 계좌의 잔액이 변하지 않았어야 함 (롤백 성공)
        BigDecimal finalKrAmount = krRepository.findByAccountNumberNoLock(senderBank.getAccountNumber())
                .map(BankKR::getAmount).orElse(BigDecimal.ZERO);
        BigDecimal finalJpAmount = jpRepository.findByAccountNumberNoLock(receiverBank.getAccountNumber())
                .map(BankJP::getAmount).orElse(BigDecimal.ZERO);

        assertEquals(initialKrAmount.stripTrailingZeros(), finalKrAmount.stripTrailingZeros(), "한국 계좌 잔액이 롤백되어야 합니다.");
        assertEquals(initialJpAmount.stripTrailingZeros(), finalJpAmount.stripTrailingZeros(), "일본 계좌 잔액에 변화가 없어야 합니다.");
    }
}

// 즉 테스트 코드에서는 기본 로직 코드에서 데드락이 일어나기 떄문에 테스트를 위해 repo에 임시 메소드로 체크하는거임
//데드락 (이번 문제의 직접 원인)
//테스트 트랜잭션 T1 시작
//    │
//            ├─ krRepository.findByAccountNumber() → KR-1001-0001 행에 FOR UPDATE 락 획득 (T1)
//    │
//            └─ transferService.transfer() 호출
//            │
//                    └─ 서비스 @Transactional → JTA 환경에서 T1에 참여
//                    │
//                            └─ krRepository.findByAccountNumber() → 같은 행에 FOR UPDATE 락 요청
//                            │
//                                    └─ 💥 T1이 이미 잡고 있는 락을 T1이 또 요청
//                                    → 자기 자신을 기다리는 데드락
//                                    → 타임아웃
