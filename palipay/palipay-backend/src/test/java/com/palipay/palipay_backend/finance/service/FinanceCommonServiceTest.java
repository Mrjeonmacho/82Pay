package com.palipay.palipay_backend.finance.service;

import static org.junit.jupiter.api.Assertions.*;

import com.palipay.palipay_backend.finance.domain.WalletPali;
import com.palipay.palipay_backend.finance.dto.ExternalTransferResultDto;
import com.palipay.palipay_backend.finance.dto.FinanceCommonDto;
import com.palipay.palipay_backend.finance.dto.TransferPersistResultDto;
import com.palipay.palipay_backend.finance.dto.response.FinanceTransferResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.AssertionsForClassTypes.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class FinanceCommonServiceTest {

    @Mock
    private TransferValidationCommonService transferValidationCommonService;

    @Mock
    private ExternalCommonBankService externalCommonBankService;

    @Mock
    private TransferCommonPersistenceService transferCommonPersistenceService;

    @Mock
    private TransferCommonRecoverySupportService transferCommonRecoverySupportService;

    @InjectMocks
    private FinanceCommonService financeCommonService;

    private Long userId;
    private String idempotencyKey;
    private WalletPali walletPaliReq;
    private WalletPali validatedWalletPali;
    private FinanceCommonDto financeCommonDto;
    private String pinNumber;
    private Long workplaceId;

    @BeforeEach
    void setUp() {
        userId = 1L;
        idempotencyKey = "idem-key-123";
        walletPaliReq = mock(WalletPali.class);
        validatedWalletPali = mock(WalletPali.class);
        financeCommonDto = mock(FinanceCommonDto.class);
        pinNumber = "1234";
        workplaceId = 10L;

        //when(walletPaliReq.getWalletId()).thenReturn(100L);
    }

    @Test
    @DisplayName("정상 흐름 시 성공 응답 반환")
    void transfer_success() {
        when(walletPaliReq.getWalletId()).thenReturn(100L);

        ExternalTransferResultDto externalResult = mock(ExternalTransferResultDto.class);
        TransferPersistResultDto persistResult = mock(TransferPersistResultDto.class);

        when(transferValidationCommonService.validate(userId, walletPaliReq, financeCommonDto))
                .thenReturn(validatedWalletPali);
        when(externalCommonBankService.transfer(eq(financeCommonDto), anyString()))
                .thenReturn(externalResult);
        when(externalResult.success()).thenReturn(true);

        when(transferCommonPersistenceService.persist(
                userId,
                walletPaliReq.getWalletId(),
                workplaceId,
                financeCommonDto,
                externalResult
        )).thenReturn(persistResult);

        when(persistResult.transactionId()).thenReturn(1L);
        when(persistResult.currentBalance()).thenReturn(new BigDecimal("5000.00"));
        when(persistResult.createdAt()).thenReturn(LocalDateTime.of(2026, 3, 12, 12, 0));

        FinanceTransferResponse response = financeCommonService.transfer(
                userId, idempotencyKey, walletPaliReq, financeCommonDto, pinNumber, workplaceId
        );

        assertThat(response).isNotNull();
    }

    @Test
    @DisplayName("검증 단계에서 예외가 발생하면 이후 로직은 실행되지 않는다")
    void transfer_fail_when_validation_throws() {
        when(transferValidationCommonService.validate(userId, walletPaliReq, financeCommonDto))
                .thenThrow(new IllegalArgumentException("잔액 부족"));

        assertThatThrownBy(() ->
                financeCommonService.transfer(
                        userId,
                        idempotencyKey,
                        walletPaliReq,
                        financeCommonDto,
                        pinNumber,
                        workplaceId
                )
        ).isInstanceOf(IllegalArgumentException.class)
                .hasMessage("잔액 부족");

        verify(externalCommonBankService, never()).transfer(any(), anyString());
        verify(transferCommonPersistenceService, never()).persist(anyLong(), anyLong(), any(), any(), any());
        verify(transferCommonRecoverySupportService, never()).onExternalSuccessBeforePersist(
                anyLong(), anyString(), any(), any()
        );
        verify(transferCommonRecoverySupportService, never()).onPersistSuccess(
                anyLong(), anyString(), any(), any()
        );
        verify(transferCommonRecoverySupportService, never()).onPersistFailure(
                anyLong(), anyString(), any(), any(), any()
        );
    }

    @Test
    @DisplayName("외부 API 호출 자체가 예외를 던지면 그대로 전파된다")
    void transfer_fail_when_external_service_throws() {
        when(transferValidationCommonService.validate(userId, walletPaliReq, financeCommonDto))
                .thenReturn(validatedWalletPali);

        when(externalCommonBankService.transfer(eq(financeCommonDto), anyString()))
                .thenThrow(new RuntimeException("external timeout"));

        assertThatThrownBy(() ->
                financeCommonService.transfer(
                        userId,
                        idempotencyKey,
                        walletPaliReq,
                        financeCommonDto,
                        pinNumber,
                        workplaceId
                )
        ).isInstanceOf(RuntimeException.class)
                .hasMessage("external timeout");

        verify(transferCommonPersistenceService, never()).persist(anyLong(), anyLong(), any(), any(), any());
        verify(transferCommonRecoverySupportService, never()).onExternalSuccessBeforePersist(
                anyLong(), anyString(), any(), any()
        );
    }

    @Test
    @DisplayName("외부 송금 응답이 실패이면 IllegalArgumentException이 발생한다")
    void transfer_fail_when_external_result_is_unsuccessful() {
        ExternalTransferResultDto externalResult = mock(ExternalTransferResultDto.class);

        when(transferValidationCommonService.validate(userId, walletPaliReq, financeCommonDto))
                .thenReturn(validatedWalletPali);

        when(externalCommonBankService.transfer(eq(financeCommonDto), anyString()))
                .thenReturn(externalResult);

        when(externalResult.success()).thenReturn(false);

        assertThatThrownBy(() ->
                financeCommonService.transfer(
                        userId,
                        idempotencyKey,
                        walletPaliReq,
                        financeCommonDto,
                        pinNumber,
                        workplaceId
                )
        ).isInstanceOf(IllegalArgumentException.class)
                .hasMessage("거래 실패 예외처리");

        verify(transferCommonRecoverySupportService, never()).onExternalSuccessBeforePersist(
                anyLong(), anyString(), any(), any()
        );
        verify(transferCommonPersistenceService, never()).persist(anyLong(), anyLong(), any(), any(), any());
    }

    @Test
    @DisplayName("외부 성공 후 복구로그 선저장 단계 실패 시 전체 실패한다")
    void transfer_fail_when_recovery_before_persist_throws() {
        ExternalTransferResultDto externalResult = mock(ExternalTransferResultDto.class);

        when(transferValidationCommonService.validate(userId, walletPaliReq, financeCommonDto))
                .thenReturn(validatedWalletPali);

        when(externalCommonBankService.transfer(eq(financeCommonDto), anyString()))
                .thenReturn(externalResult);

        when(externalResult.success()).thenReturn(true);

        doThrow(new RuntimeException("recovery log save fail"))
                .when(transferCommonRecoverySupportService)
                .onExternalSuccessBeforePersist(userId, idempotencyKey, financeCommonDto, externalResult);

        assertThatThrownBy(() ->
                financeCommonService.transfer(
                        userId,
                        idempotencyKey,
                        walletPaliReq,
                        financeCommonDto,
                        pinNumber,
                        workplaceId
                )
        ).isInstanceOf(RuntimeException.class)
                .hasMessage("recovery log save fail");

        verify(transferCommonPersistenceService, never()).persist(anyLong(), anyLong(), any(), any(), any());
    }

    @Test
    @DisplayName("DB 저장 실패 시 onPersistFailure가 호출되고 IllegalArgumentException이 발생한다")
    void transfer_fail_when_persist_throws() {
        ExternalTransferResultDto externalResult = mock(ExternalTransferResultDto.class);

        when(transferValidationCommonService.validate(userId, walletPaliReq, financeCommonDto))
                .thenReturn(validatedWalletPali);

        when(externalCommonBankService.transfer(eq(financeCommonDto), anyString()))
                .thenReturn(externalResult);

        when(externalResult.success()).thenReturn(true);

        doNothing().when(transferCommonRecoverySupportService)
                .onExternalSuccessBeforePersist(userId, idempotencyKey, financeCommonDto, externalResult);

        when(transferCommonPersistenceService.persist(
                userId,
                walletPaliReq.getWalletId(),
                workplaceId,
                financeCommonDto,
                externalResult
        )).thenThrow(new RuntimeException("db save fail"));

        assertThatThrownBy(() ->
                financeCommonService.transfer(
                        userId,
                        idempotencyKey,
                        walletPaliReq,
                        financeCommonDto,
                        pinNumber,
                        workplaceId
                )
        ).isInstanceOf(IllegalArgumentException.class)
                .hasMessage("실패 예외 던지기");

        verify(transferCommonRecoverySupportService).onPersistFailure(
                eq(userId),
                eq(idempotencyKey),
                eq(financeCommonDto),
                eq(externalResult),
                any(RuntimeException.class)
        );
        verify(transferCommonRecoverySupportService, never()).onPersistSuccess(
                anyLong(), anyString(), any(), any()
        );
    }

    @Test
    @DisplayName("DB 저장 실패 후 onPersistFailure도 실패하면 복구 실패 예외가 원래 예외를 덮어쓴다")
    void transfer_fail_when_persist_failure_handler_also_throws() {
        ExternalTransferResultDto externalResult = mock(ExternalTransferResultDto.class);

        when(transferValidationCommonService.validate(userId, walletPaliReq, financeCommonDto))
                .thenReturn(validatedWalletPali);

        when(externalCommonBankService.transfer(eq(financeCommonDto), anyString()))
                .thenReturn(externalResult);

        when(externalResult.success()).thenReturn(true);

        when(transferCommonPersistenceService.persist(
                userId,
                walletPaliReq.getWalletId(),
                workplaceId,
                financeCommonDto,
                externalResult
        )).thenThrow(new RuntimeException("db save fail"));

        doThrow(new RuntimeException("recovery fail"))
                .when(transferCommonRecoverySupportService)
                .onPersistFailure(eq(userId), eq(idempotencyKey), eq(financeCommonDto), eq(externalResult), any());

        assertThatThrownBy(() ->
                financeCommonService.transfer(
                        userId,
                        idempotencyKey,
                        walletPaliReq,
                        financeCommonDto,
                        pinNumber,
                        workplaceId
                )
        ).isInstanceOf(RuntimeException.class)
                .hasMessage("recovery fail");
    }

    @Test
    @DisplayName("DB 저장은 성공했지만 onPersistSuccess가 실패하면 전체 요청이 실패한다")
    void transfer_fail_when_on_persist_success_throws() {
        ExternalTransferResultDto externalResult = mock(ExternalTransferResultDto.class);
        TransferPersistResultDto persistResult = mock(TransferPersistResultDto.class);

        when(transferValidationCommonService.validate(userId, walletPaliReq, financeCommonDto))
                .thenReturn(validatedWalletPali);

        when(externalCommonBankService.transfer(eq(financeCommonDto), anyString()))
                .thenReturn(externalResult);

        when(externalResult.success()).thenReturn(true);

        when(transferCommonPersistenceService.persist(
                userId,
                walletPaliReq.getWalletId(),
                workplaceId,
                financeCommonDto,
                externalResult
        )).thenReturn(persistResult);

        doThrow(new RuntimeException("post persist hook fail"))
                .when(transferCommonRecoverySupportService)
                .onPersistSuccess(userId, idempotencyKey, financeCommonDto, externalResult);

        assertThatThrownBy(() ->
                financeCommonService.transfer(
                        userId,
                        idempotencyKey,
                        walletPaliReq,
                        financeCommonDto,
                        pinNumber,
                        workplaceId
                )
        ).isInstanceOf(RuntimeException.class)
                .hasMessage("post persist hook fail");
    }

    @Test
    @DisplayName("persistResultDto.createdAt가 null이면 NPE가 발생한다")
    void transfer_fail_when_created_at_is_null() {
        ExternalTransferResultDto externalResult = mock(ExternalTransferResultDto.class);
        TransferPersistResultDto persistResult = mock(TransferPersistResultDto.class);

        when(transferValidationCommonService.validate(userId, walletPaliReq, financeCommonDto))
                .thenReturn(validatedWalletPali);

        when(externalCommonBankService.transfer(eq(financeCommonDto), anyString()))
                .thenReturn(externalResult);

        when(externalResult.success()).thenReturn(true);

        when(transferCommonPersistenceService.persist(
                userId,
                walletPaliReq.getWalletId(),
                workplaceId,
                financeCommonDto,
                externalResult
        )).thenReturn(persistResult);

        when(persistResult.transactionId()).thenReturn(1L);
        when(persistResult.currentBalance()).thenReturn(new BigDecimal("1000.00"));
        when(persistResult.createdAt()).thenReturn(null);

        assertThatThrownBy(() ->
                financeCommonService.transfer(
                        userId,
                        idempotencyKey,
                        walletPaliReq,
                        financeCommonDto,
                        pinNumber,
                        workplaceId
                )
        ).isInstanceOf(NullPointerException.class);
    }
}