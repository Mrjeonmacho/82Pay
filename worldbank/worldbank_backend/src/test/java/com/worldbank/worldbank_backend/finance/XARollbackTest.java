package com.worldbank.worldbank_backend.finance;

import com.worldbank.worldbank_backend.finance.domain.dto.TransferRequestDto;
import com.worldbank.worldbank_backend.finance.domain.entity.jp.BankJP;
import com.worldbank.worldbank_backend.finance.domain.entity.kr.BankKR;
import com.worldbank.worldbank_backend.finance.domain.repository.jp.BankJPRepository;
import com.worldbank.worldbank_backend.finance.domain.repository.kr.BankKRRepository;
import com.worldbank.worldbank_backend.finance.domain.service.TransferService;
import jakarta.transaction.Transactional;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.math.BigDecimal;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.junit.jupiter.api.Assertions.assertEquals;

@SpringBootTest
public class XARollbackTest {

    @Autowired
    private TransferService transferService;

    @Autowired
    private BankKRRepository krRepository;

    @Autowired
    private BankJPRepository jpRepository;
@Test
@DisplayName("XA 분산 트랜잭션 롤백 테스트: 출금 후 입금 전 예외 발생 시나리오")
void xaDistributedTransactionRollbackTest() {
    // 1. 초기 잔액 조회 (락 없는 메서드 사용)
    BigDecimal initialKrAmount = krRepository.findByAccountNumberNoLock("KR-1001-0001")
            .map(BankKR::getAmount).orElse(BigDecimal.ZERO);
    BigDecimal initialJpAmount = jpRepository.findByAccountNumberNoLock("JP-2001-0001")
            .map(BankJP::getAmount).orElse(BigDecimal.ZERO);

    // 2. 강제로 에러가 발생할 수밖에 없는 요청
    TransferRequestDto request = TransferRequestDto.builder()
            .senderAccountNumber("KR-1001-0001")
            .senderBankcode("KR")
            .targetAccountNumber("INVALID-ACCOUNT") // 에러 유발
            .targetBankcode("JP")
            .senderAmount(new BigDecimal("1000.00"))
            .targetAmount(new BigDecimal("10.00"))
            .build();

    // 3. 실행 및 롤백 확인
    assertThatThrownBy(() -> transferService.transfer(request))
            .isInstanceOf(RuntimeException.class);

    // 4. DB 확인: 두 계좌의 잔액이 변하지 않았어야 함 (롤백 성공)
    BigDecimal finalKrAmount = krRepository.findByAccountNumberNoLock("KR-1001-0001")
            .map(BankKR::getAmount).orElse(BigDecimal.ZERO);
    BigDecimal finalJpAmount = jpRepository.findByAccountNumberNoLock("JP-2001-0001")
            .map(BankJP::getAmount).orElse(BigDecimal.ZERO);

    assertEquals(initialKrAmount, finalKrAmount, "한국 계좌 잔액이 롤백되어야 합니다.");
    assertEquals(initialJpAmount, finalJpAmount, "일본 계좌 잔액에 변화가 없어야 합니다.");
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
