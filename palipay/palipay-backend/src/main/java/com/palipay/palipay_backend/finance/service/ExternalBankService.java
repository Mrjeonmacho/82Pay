package com.palipay.palipay_backend.finance.service;

import com.palipay.palipay_backend.external.dto.request.ExternalTransferRequest;
import com.palipay.palipay_backend.external.dto.response.ExternalTransferResponse;
import com.palipay.palipay_backend.external.service.ExternalBankClient;
import com.palipay.palipay_backend.finance.domain.WalletPali;
import com.palipay.palipay_backend.finance.dto.ExternalTransferResultDto;
import com.palipay.palipay_backend.finance.dto.request.FinanceTransferRequest;
import com.palipay.palipay_backend.global.bank.BankCode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ExternalBankService {

    private final ExternalBankClient externalBankClient;

    public ExternalTransferResultDto transfer(
            WalletPali walletPali,
            FinanceTransferRequest request,
            String transferId){

        //FIXME bankCode 타입 문제
        ExternalTransferRequest externTransReq = new ExternalTransferRequest(
                walletPali.getAccountNumber(),
                walletPali.getAccountUsername(),
                //walletPali.getBankCode(),
                BankCode.ABOCCNBJ,
                request.amount(),
                "KR",

                request.otherAccountNumber(),
                request.otherAccountName(),
                //request.otherBankCode(),
                BankCode.ABOCCNBJ,
                request.amount(),
                "KR",

                request.description()
        );

        ExternalTransferResponse response = externalBankClient.transfer(externTransReq);

        //FIXME 외부 ID는 따로 없음 transferId를 그대로 반환
        if (response.success()) {
            return ExternalTransferResultDto.success(
                    transferId,
                    response.rawResponse()
            );
        }

        return ExternalTransferResultDto.failed(
                transferId,
                response.rawResponse()
        );
    }
}
