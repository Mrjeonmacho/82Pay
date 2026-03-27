package com.palipay.palipay_backend.finance.service;

import com.palipay.palipay_backend.external.dto.request.ExternalCheckRequest;
import com.palipay.palipay_backend.external.dto.response.ExternalCheckResponse;
import com.palipay.palipay_backend.finance.domain.WalletPali;
import com.palipay.palipay_backend.finance.dto.request.BalanceCheckRequest;
import com.palipay.palipay_backend.finance.dto.request.ExAccValidateRequest;
import com.palipay.palipay_backend.finance.dto.request.PinValidateRequest;
import com.palipay.palipay_backend.finance.dto.response.BalanceCheckResponse;
import com.palipay.palipay_backend.finance.dto.response.ExAccValidateResponse;
import com.palipay.palipay_backend.finance.dto.response.PinValidateResponse;
import com.palipay.palipay_backend.global.bank.BankCode;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class FinanceValidationService {

    private final WalletService walletService;
    private final ExternalCommonBankService externalCommonBankService;

    private final WorkplaceService workplaceService;

    public BalanceCheckResponse checkBalance(
            Long userId,
            BalanceCheckRequest request) {

        WalletPali walletPali = walletService.getWalletPali(request.walletId());

        // FIXME 예외 하드코딩
        if (!walletPali.isOwnedBy(userId)) {
            throw new IllegalArgumentException("해당 wallet의 사용자가 아님");
        }

        /* 요청 금액이 지갑 잔액보다 적으면 성공 */
        if (request.amount().compareTo(walletPali.getAmount()) <= 0) {
            return BalanceCheckResponse.sufficient(
                    walletPali.getAmount(),
                    request.amount());
        }

        /* 요청 금액이 지갑 잔액보다 많으면 실패 */
        return BalanceCheckResponse.insufficient(
                walletPali.getAmount(),
                request.amount(),
                request.amount().subtract(walletPali.getAmount()));
    }

    public PinValidateResponse checkPin(
            Long userId,
            PinValidateRequest request) {
        WalletPali walletPali = walletService.getWalletPali(request.walletId());

        // FIXME 예외 하드코딩
        if (!walletPali.isOwnedBy(userId)) {
            throw new IllegalArgumentException("해당 wallet의 사용자가 아님");
        }

        if (walletPali.matchesPin(request.pinNumber())) {
            return PinValidateResponse.valid();
        }
        return PinValidateResponse.inValid();
    }

    public ExAccValidateResponse checkExternAccount(
            ExAccValidateRequest request) {
        // FIXME bankcode 하드코딩 중
        ExternalCheckRequest exReq = new ExternalCheckRequest(
                request.otherAccountNumber(),
                request.otherAccountName(),
                request.otherBankCode() != null ? BankCode.valueOf(request.otherBankCode()) : null,
                request.accountCurrency());
        ExternalCheckResponse response = externalCommonBankService.checkAccount(exReq);

        if (!response.success()) {
            String errorMsg = (response.message() != null) ? response.message() : "외부 은행에서 계좌를 찾을 수 없습니다.";
            log.error("❌ 계좌 검증 실패 사유: {}", errorMsg); // 백엔드 로그에 찍기
            return new ExAccValidateResponse(false, null, null, errorMsg);
        }

        Long workplaceId = workplaceService.getWorkplaceId(request.otherAccountNumber())
                .orElse(null);

        return new ExAccValidateResponse(true, response.amount(), workplaceId, "계좌 검증 성공");
    }
}
