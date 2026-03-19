package com.palipay.palipay_backend.finance.service;


import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.palipay.palipay_backend.external.dto.request.ExternalCheckRequest;
import com.palipay.palipay_backend.external.dto.request.ExternalTransferRequest;
import com.palipay.palipay_backend.external.dto.response.ExternalCheckResponse;
import com.palipay.palipay_backend.external.dto.response.ExternalTransferResponse;
import com.palipay.palipay_backend.external.service.ExternalBankClient;
import com.palipay.palipay_backend.finance.dto.ExternalTransferResultDto;
import com.palipay.palipay_backend.finance.dto.FinanceCommonDto;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ExternalCommonBankService {

    private final ExternalBankClient externalBankClient;
    private final ObjectMapper objectMapper;

    public ExternalCheckResponse checkAccount(
            ExternalCheckRequest request
    ){
        return externalBankClient.checkValue(request);
    }

    public ExternalTransferResultDto transfer(
            FinanceCommonDto req,
            String transferId){

        ExternalTransferRequest externTransReq = new ExternalTransferRequest(
                req.sourceAccountNumber(),
                req.sourceAccountName(),
                req.sourceBankCode(),
                req.sourceAmount(),
                req.sourceCurrency(),

                req.targetAccountNumber(),
                req.targetAccountName(),
                req.targetBankCode(),
                req.targetAmount(),
                req.targetCurrency(),

                req.description()
        );

        ExternalTransferResponse response = externalBankClient.transferCommon(externTransReq);
        String rawResponse = toRawResponse(response);


        //FIXME 외부 ID는 따로 없음 transferId를 그대로 반환
        if (response.success()) {
            return ExternalTransferResultDto.success(
                    transferId,
                    rawResponse
            );
        }

        return ExternalTransferResultDto.failed(
                transferId,
                rawResponse
        );
    }

    private String toRawResponse(ExternalTransferResponse response){
        try{
            return objectMapper.writeValueAsString(response);
        }catch (JsonProcessingException e){
            return "{\"message\":\"response serialization failed\"}";
        }
    }
}
