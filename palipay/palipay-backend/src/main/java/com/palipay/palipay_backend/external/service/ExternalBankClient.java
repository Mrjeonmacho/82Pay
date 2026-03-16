package com.palipay.palipay_backend.external.service;

import com.palipay.palipay_backend.external.dto.request.ExternalTransferRequest;
import com.palipay.palipay_backend.external.dto.response.ExternalTransferResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;

@Component
@RequiredArgsConstructor
public class ExternalBankClient {
    public ExternalTransferResponse transfer(ExternalTransferRequest req){

        //TODO restTemplate.postForObject 방식으로 api 전송

        //TODO 반환
        /*
                boolean success,
        String status,
        String message,
        String rawResponse
         */
        ExternalTransferResponse.TransferData data =
                new ExternalTransferResponse.TransferData(
                        req.senderAccountNumber(),
                        req.senderAccountName(),
                        req.senderBankCode().name(),
                        req.senderAmount(),
                        req.targetAccountNumber(),
                        req.targetAccountName(),
                        req.targetBankCode().name(),
                        req.targetAmount(),
                        req.targetCurrency(),
                        req.senderCurrency()
                );

        return ExternalTransferResponse.success(
                "이체가 정상적으로 완료되었습니다.",
                data
        );
    }

    public ExternalTransferResponse transferCommon(ExternalTransferRequest req) {
        //TEST 입력에 1_000_000 이상 금액을 입력하면 에러 처리 강제 발생 설정
        if (req.senderAmount().compareTo(BigDecimal.valueOf(1_000_000)) > 0) {
            return ExternalTransferResponse.fail(
                    "이체에 실패했습니다.",
                    "INSUFFICIENT_BALANCE",
                    "잔액이 부족하여 거래를 완료할 수 없습니다."
            );
        }

        ExternalTransferResponse.TransferData data =
                new ExternalTransferResponse.TransferData(
                        req.senderAccountNumber(),
                        req.senderAccountName(),
                        req.senderBankCode().name(),
                        req.senderAmount(),
                        req.targetAccountNumber(),
                        req.targetAccountName(),
                        req.targetBankCode().name(),
                        req.targetAmount(),
                        req.targetCurrency(),
                        req.senderCurrency()
                );

        return ExternalTransferResponse.success(
                "이체가 정상적으로 완료되었습니다.",
                data
        );
    }

//    public ExternalTransferResponse checkValue(ExternalCheckRequest req){
//        /*TODO 외부 은행 잔액 확인 요청*/
//
//
//    }

}
