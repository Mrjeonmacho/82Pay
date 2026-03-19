package com.palipay.palipay_backend.external.service;

import com.palipay.palipay_backend.external.dto.request.ExternalCheckRequest;
import com.palipay.palipay_backend.external.dto.request.ExternalRealRequest;
import com.palipay.palipay_backend.external.dto.request.ExternalTransferRequest;
import com.palipay.palipay_backend.external.dto.response.ExternalCheckResponse;
import com.palipay.palipay_backend.external.dto.response.ExternalRealResponse;
import com.palipay.palipay_backend.external.dto.response.ExternalTransferResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

import java.math.BigDecimal;

@Component
@RequiredArgsConstructor
public class ExternalBankClient {

    private final RestClient externalFinanceRestClient;

    public ExternalTransferResponse transferCommon(ExternalTransferRequest req) {

        ExternalRealRequest requestDto = toExternalRealRequest(req);
        try {
            ExternalRealResponse response = externalFinanceRestClient.patch()
                    .uri("/api/finance")
                    .body(requestDto)
                    .retrieve()
                    .body(ExternalRealResponse.class);

            if (response == null) {
                return ExternalTransferResponse.fail(
                        "이체에 실패했습니다.",
                        "EMPTY_RESPONSE",
                        "외부 금융 서버로부터 응답이 없습니다."
                );
            }

            return toExternalTransferResponse(response);
        } catch (RestClientException e) {

            return ExternalTransferResponse.fail(
                    "이체에 실패했습니다.",
                    "EXTERNAL_API_ERROR",
                    "외부 금융 서버 호출 중 오류가 발생했습니다. " + e.getMessage()
            );
        }
    }

    //TODO 추후 DTO 수정
    public ExternalCheckResponse checkValue(ExternalCheckRequest req){
        /*TODO 외부 은행 잔액 확인 요청*/
        try {
            ExternalCheckResponse response = externalFinanceRestClient.get()
                    .uri("/api/finance/{accountId}", req.targetAccountNumber())
                    .retrieve()
                    .body(ExternalCheckResponse.class);

            if (response == null) {
                return new ExternalCheckResponse(
                        "서버 응답 없음",
                        null,
                        null
                );
            }

            return response;

        } catch (RestClientException e) {

            return new ExternalCheckResponse(
                    "계좌 확인에 실패했습니다." + e.getMessage(),
                    null,
                    null
            );
        }
    }

    private ExternalRealRequest toExternalRealRequest(ExternalTransferRequest req) {
        return ExternalRealRequest.builder()
                .senderAccountNumber(req.senderAccountNumber())
                .senderAccountName(req.senderAccountName())
                .senderBankcode(req.senderBankCode().name())
                .targetAccountNumber(req.targetAccountNumber())
                .targetAccountName(req.targetAccountName())
                .targetBankcode(req.targetBankCode().name())
                .senderAmount(req.senderAmount())
                .targetAmount(req.targetAmount())
                .senderCurrency(req.senderCurrency())
                .targetCurrency(req.targetCurrency())
                .build();
    }

    private ExternalTransferResponse toExternalTransferResponse(ExternalRealResponse res) {

        if (res == null) {
            return ExternalTransferResponse.fail(
                    "외부 금융 서버 응답이 없습니다.",
                    "EMPTY_RESPONSE",
                    "External service returned null"
            );
        }

        ExternalTransferResponse.TransferData data =
                new ExternalTransferResponse.TransferData(
                        res.getSenderAccountNumber(),
                        res.getSenderAccountName(),
                        res.getSenderBankcode(),
                        res.getSenderAmount(),
                        res.getTargetAccountNumber(),
                        res.getTargetAccountName(),
                        res.getTargetBankcode(),
                        res.getTargetAmount(),
                        res.getTargetCurrency(),
                        res.getSenderCurrency()
                );

        return ExternalTransferResponse.success(
                res.getMessage(),
                data
        );
    }

}
