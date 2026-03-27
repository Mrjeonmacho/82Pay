package com.palipay.palipay_backend.external.service;

import com.palipay.palipay_backend.external.dto.request.ExternalCheckRequest;
import com.palipay.palipay_backend.external.dto.request.ExternalLinkRequest;
import com.palipay.palipay_backend.external.dto.request.ExternalRealRequest;
import com.palipay.palipay_backend.external.dto.request.ExternalTransferRequest;
import com.palipay.palipay_backend.external.dto.response.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.client.*;

import java.util.Optional;

@Component
@RequiredArgsConstructor
@Slf4j
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

    public Optional<ExternalWorkplaceResponse> workplaceInfo(String accountNumber){

        try{
            ExternalWorkplaceResponse response = externalFinanceRestClient.get()
                    .uri("/api/finance/corporation/{accountNumber}", accountNumber)
                    .retrieve()
                    .body(ExternalWorkplaceResponse.class);

            return Optional.ofNullable(response);

        } catch (RestClientException e) {
            log.warn("외부 사업장 조회 실패 accountNumber={}", accountNumber, e);
            return Optional.empty();
        }

    }

    //TODO 추후 DTO 수정
    public ExternalCheckResponse checkValue(ExternalCheckRequest req){
        /*TODO 외부 은행 잔액 확인 요청*/
        try {
            ExternalCheckResponse response = externalFinanceRestClient.get()
                    .uri(uriBuilder -> uriBuilder
                            .path("/api/finance/check")
                            .queryParam("targetAccountNumber", req.targetAccountNumber())
                            .queryParam("targetAccountName", req.targetAccountName())
                            .queryParam("targetBankCode", req.targetBankCode())
                            .queryParam("targetCurrency", req.targetCurrency())
                            .build()
                    ).retrieve()
                    .body(ExternalCheckResponse.class);

            if (response == null || response.success() == null) {
                return new ExternalCheckResponse(
                        Boolean.FALSE,
                        "서버 응답 없음",
                        null,
                        null,
                        null
                );
            }

            return response;

        } catch (RestClientException e) {
            return new ExternalCheckResponse(
                    Boolean.FALSE,
                    "계좌 확인에 실패했습니다." + e.getMessage(),
                    null,
                    null,
                    null
            );
        } catch (Exception e){
            return new ExternalCheckResponse(
                    Boolean.FALSE,
                    "먼가 이상한 오류임" + e.getMessage(),
                    null,
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

    public ExternalLinkResponse linkAccount(ExternalLinkRequest req){
        try{
            ExternalLinkResponse response = externalFinanceRestClient.post()
                    .uri("/api/finance/Link")
                    .body(req)
                    .retrieve()
                    .body(ExternalLinkResponse.class);

            return response;

        } catch (RestClientException e) {
            log.warn("계좌 등록 실패", e);

            return new ExternalLinkResponse(
                    "계좌 등록 실패" + e.getMessage(),
                    Boolean.FALSE
            );
        }
    }

}
