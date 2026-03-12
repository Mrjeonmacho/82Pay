package com.palipay.palipay_backend.external.service;

import com.palipay.palipay_backend.external.dto.request.ExternalTransferRequest;
import com.palipay.palipay_backend.external.dto.response.ExternalTransferResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

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
        ExternalTransferResponse response = new ExternalTransferResponse(
                Boolean.TRUE,
                "SUCCESS",
                "SUCCESS",
                "TEST"
        );
        return response;
    }
}
