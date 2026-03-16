package com.palipay.palipay_backend.finance.service;

import com.palipay.palipay_backend.finance.domain.WalletPali;
import com.palipay.palipay_backend.finance.dto.ExternalTransferResultDto;
import com.palipay.palipay_backend.finance.dto.FinanceCommonDto;
import com.palipay.palipay_backend.finance.dto.TransferPersistResultDto;
import com.palipay.palipay_backend.finance.dto.TransferResultCacheDto;
import com.palipay.palipay_backend.finance.dto.response.FinanceTransferResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class FinanceCommonService {
    //TODO 중복 토큰 방지 서비스
    //TODO 사업자 정보 요청 서비스
    //검증 서비스
    private final TransferValidationCommonService transferValidationCommonService;
    //송금 외부 api 요청
    private final ExternalCommonBankService externalCommonBankService;
    //내부 지갑, 기록 동기화
    private final TransferCommonPersistenceService transferCommonPersistenceService;
    //복구 로그 서비스(옵션)
    private final TransferCommonRecoverySupportService transferCommonRecoverySupportService;

    public FinanceTransferResponse transfer(
            Long userId,
            String idempotencyKey,
            WalletPali walletPaliReq,
            FinanceCommonDto financeCommandDto,
            String pinNumber,
            Long workplaceId
    ){

        //TODO 중복 체크 서비스 로직 lock

        try{
            WalletPali walletPali = transferValidationCommonService.validate(
                    userId,
                    walletPaliReq,
                    financeCommandDto
            );

            //FIXME transfer ID 사용 안 할 가능성 높음
            //FIXME redis 설정에 필요할 수도 있긴 함
            String transferId = generateTransferId();

            ExternalTransferResultDto externalTransferResultDto =
                    externalCommonBankService.transfer(
                            financeCommandDto,
                            transferId
                    );

            //TODO 예외 거래 실패 예외처리
            if(!externalTransferResultDto.success()){
                throw new IllegalArgumentException("거래 실패 예외처리");
            }

            //db에 저장하기 이전 복구 테이블에 거래 저장
            transferCommonRecoverySupportService.onExternalSuccessBeforePersist(
                    userId,
                    idempotencyKey,
                    financeCommandDto,
                    externalTransferResultDto
            );

            //거래 내역 결과
            TransferPersistResultDto persistResultDto;

            try{
                persistResultDto = transferCommonPersistenceService.persist(
                        userId,
                        walletPaliReq.getWalletId(),
                        workplaceId,
                        financeCommandDto,
                        externalTransferResultDto
                );
            } catch (Exception exception){
                //저장 실패시 복구 로직 동작
                //TODO 실패 복구 구현
                transferCommonRecoverySupportService.onPersistFailure(
                        userId,
                        idempotencyKey,
                        financeCommandDto,
                        externalTransferResultDto,
                        exception
                );
                //TODO 예외 구체화
                throw new IllegalArgumentException("거래저장에 실패했습니다!", exception);
            }

            //db 저장 성공 시 작동
            transferCommonRecoverySupportService.onPersistSuccess(
                    userId,
                    idempotencyKey,
                    financeCommandDto,
                    externalTransferResultDto
            );


            //db 저장 성공 시 작동
            TransferResultCacheDto resultCacheDto = new TransferResultCacheDto(
                    transferId,
                    persistResultDto.transactionId(),
                    "SUCCESS",
                    persistResultDto.currentBalance(),
                    persistResultDto.createdAt().toString()
            );

            //TODO redis save result


            return FinanceTransferResponse.success(
                    resultCacheDto.transferId(),
                    resultCacheDto.transactionId(),
                    resultCacheDto.currentBalance(),
                    resultCacheDto.createdAt()
            );
        }finally {
            //TODO unlock

        }
    }

    //FIXME 실제 사용 안할 수 있음
    private String generateTransferId() {
        return "trf_" + UUID.randomUUID().toString().replace("-", "").substring(0, 8);
    }
}
