package com.palipay.palipay_backend.finance.service;

import com.palipay.palipay_backend.external.dto.request.ExternalLinkRequest;
import com.palipay.palipay_backend.external.dto.response.ExternalLinkResponse;
import com.palipay.palipay_backend.external.service.ExternalBankClient;
import com.palipay.palipay_backend.finance.domain.WalletPali;
import com.palipay.palipay_backend.finance.dto.request.FinanceAccountRequest;
import com.palipay.palipay_backend.finance.dto.request.WalletPinRequest;
import com.palipay.palipay_backend.finance.dto.request.WalletPinUpdateRequest;
import com.palipay.palipay_backend.finance.dto.response.FinanceAccountResponse;
import com.palipay.palipay_backend.finance.dto.response.WalletPinResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class FinanceAccountService {
    private final ExternalBankClient externalBankClient;
    private final WalletService walletService;

    public FinanceAccountResponse connectWallet(
            Long userId,
            FinanceAccountRequest request
    ){
        Long walletId = request.walletId();
        String bankCode = request.bankCode();
        String accountNumber = request.accountNumber();
        String accountUsername = request.accountUsername();
        String accountPassword = request.accountPassword();
        String moneyCode = request.moneyCode();

        //TODO 지갑 없을 시 예외 처리
        WalletPali walletPali = walletService.getWalletPali(walletId);
        if (!walletPali.isOwnedBy(userId)) {
            throw new IllegalArgumentException("해당 사용자의 지갑이 아닙니다.");
        }

        /*외부 계좌 인증*/
        ExternalLinkRequest exRequest = new ExternalLinkRequest(
                accountNumber,
                accountPassword,
                moneyCode
        );

        ExternalLinkResponse exResponse = externalBankClient.linkAccount(exRequest);

        if(!exResponse.check()){
            //TODO 예외 처리
            return new FinanceAccountResponse(
                    "fail",
                    walletId
            );
        }

        //TODO 이거 해제

        /*wallet에 계좌 정보 업데이트*/
        walletService.updateWalletPali(
                walletId,
                accountNumber,
                accountUsername,
                bankCode,
                moneyCode
        );

        return new FinanceAccountResponse(
                "success",
                walletId
        );
    }

    public WalletPinResponse createPin(
            Long userId,
            WalletPinRequest req){

        WalletPali walletPali = walletService.getWalletPaliByUserId(userId);

        walletService.updatePin(walletPali.getWalletId(), req.pinNumber());

        return WalletPinResponse.builder()
                .message("pin is created!").build();
    }

    public WalletPinResponse updatePin(
            Long userId,
            WalletPinUpdateRequest req
    ){
        WalletPali walletPali = walletService.getWalletPaliByUserId(userId);

        if(!walletPali.matchesPin(req.oldPinNumber())){
            //TODO 예외 발생
        }

        walletService.updatePin(walletPali.getWalletId(), req.newPinNumber());

        return WalletPinResponse.builder()
                .message("pin is updated!").build();
    }


}
