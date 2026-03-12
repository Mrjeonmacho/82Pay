package com.palipay.palipay_backend.finance.service;

import com.palipay.palipay_backend.finance.domain.WalletPali;
import com.palipay.palipay_backend.finance.dto.ExternalTransferResultDto;
import com.palipay.palipay_backend.finance.dto.TransferPersistResultDto;
import com.palipay.palipay_backend.finance.dto.request.FinanceTransferRequest;
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
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class FinanceTransferServiceTest {

    @Mock
    private TransferValidationService transferValidationService;

    @Mock
    private ExternalBankService externalBankService;

    @Mock
    private TransferPersistenceService transferPersistenceService;

    @Mock
    private TransferRecoverySupportService transferRecoverySupportService;

    @InjectMocks
    private FinanceTransferService financeTransferService;

    private Long userId;
    private String idempotencyKey;
    private FinanceTransferRequest request;
    private WalletPali walletPali;

    private String transferId;

    //transaction test라 user, idempotenceKey, request, wallet mock으로 설정
    @BeforeEach
    void setUp(){
        userId = 1L;
        idempotencyKey = "idem-key-123";
        request = mock(FinanceTransferRequest.class);
        walletPali = mock(WalletPali.class);
        transferId = "trf-123";
    }

    @Test
    @DisplayName("정상 흐름 시 성공 응답 반환")
    void transfer_success(){

        ExternalTransferResultDto externalTransferResultDto = mock(ExternalTransferResultDto.class);
        TransferPersistResultDto transferPersistResultDto = mock(TransferPersistResultDto.class);

        //검증 설정 -> walletPali mock return
        when(transferValidationService.validate(userId, request))
                .thenReturn(walletPali);

        //외부 요청 설정
        when(externalBankService.transfer(eq(walletPali), eq(request), anyString()))
                .thenReturn(externalTransferResultDto);

        when(externalTransferResultDto.success())
                .thenReturn(true);

        when(transferPersistenceService.persist(userId, idempotencyKey, request, externalTransferResultDto))
                .thenReturn(transferPersistResultDto);

        when(transferPersistResultDto.transactionId())
                .thenReturn(1L);
        when(transferPersistResultDto.currentBalance())
                .thenReturn(new BigDecimal("5000.00"));
        when(transferPersistResultDto.createdAt())
                .thenReturn(LocalDateTime.of(2026, 3, 12, 12, 0));

        FinanceTransferResponse response
                = financeTransferService.transfer(userId, idempotencyKey, request);

        assertThat(response).isNotNull();
        verify(transferValidationService).validate(userId, request);
        verify(externalBankService).transfer(eq(walletPali), eq(request), anyString());
        verify(transferRecoverySupportService).onExternalSuccessBeforePersist(
                userId, idempotencyKey, request, externalTransferResultDto
        );
        verify(transferPersistenceService).persist(
                userId, idempotencyKey, request, externalTransferResultDto
        );
        verify(transferRecoverySupportService).onPersistSuccess(
                userId, idempotencyKey, request, externalTransferResultDto
        );
        verify(transferRecoverySupportService, never()).onPersistFailure(
                anyLong(), anyString(), any(), any(), any()
        );
    }

    @Test
    @DisplayName("검증 단계에서 예외가 발생하면 이후 로직은 실행되지 않는다")
    void transfer_fail_when_validation_throws() {
        when(transferValidationService.validate(userId, request))
                .thenThrow(new IllegalArgumentException("잔액 부족"));

        assertThatThrownBy(() ->
                financeTransferService.transfer(userId, idempotencyKey, request)
        ).isInstanceOf(IllegalArgumentException.class)
                .hasMessage("잔액 부족");

        verify(externalBankService, never()).transfer(any(), any(), anyString());
        verify(transferPersistenceService, never()).persist(anyLong(), anyString(), any(), any());
        verify(transferRecoverySupportService, never()).onExternalSuccessBeforePersist(
                anyLong(), anyString(), any(), any()
        );
        verify(transferRecoverySupportService, never()).onPersistSuccess(
                anyLong(), anyString(), any(), any()
        );
        verify(transferRecoverySupportService, never()).onPersistFailure(
                anyLong(), anyString(), any(), any(), any()
        );
    }

    @Test
    @DisplayName("외부 API 호출 자체가 예외를 던지면 그대로 전파된다")
    void transfer_fail_when_external_service_throws() {
        when(transferValidationService.validate(userId, request)).thenReturn(walletPali);
        when(externalBankService.transfer(eq(walletPali), eq(request), anyString()))
                .thenThrow(new RuntimeException("external timeout"));

        assertThatThrownBy(() ->
                financeTransferService.transfer(userId, idempotencyKey, request)
        ).isInstanceOf(RuntimeException.class)
                .hasMessage("external timeout");

        verify(transferPersistenceService, never()).persist(anyLong(), anyString(), any(), any());
        verify(transferRecoverySupportService, never()).onExternalSuccessBeforePersist(
                anyLong(), anyString(), any(), any()
        );
    }

    @Test
    @DisplayName("외부 송금 응답이 실패이면 IllegalArgumentException이 발생한다")
    void transfer_fail_when_external_result_is_unsuccessful() {
        ExternalTransferResultDto externalResult = mock(ExternalTransferResultDto.class);

        when(transferValidationService.validate(userId, request)).thenReturn(walletPali);
        when(externalBankService.transfer(eq(walletPali), eq(request), anyString()))
                .thenReturn(externalResult);
        when(externalResult.success()).thenReturn(false);

        assertThatThrownBy(() ->
                financeTransferService.transfer(userId, idempotencyKey, request)
        ).isInstanceOf(IllegalArgumentException.class)
                .hasMessage("거래 실패 예외처리");

        verify(transferRecoverySupportService, never()).onExternalSuccessBeforePersist(
                anyLong(), anyString(), any(), any()
        );
        verify(transferPersistenceService, never()).persist(anyLong(), anyString(), any(), any());
    }

    @Test
    @DisplayName("외부 성공 후 복구로그 선저장 단계 실패 시 전체 실패한다")
    void transfer_fail_when_recovery_before_persist_throws() {
        ExternalTransferResultDto externalResult = mock(ExternalTransferResultDto.class);

        when(transferValidationService.validate(userId, request)).thenReturn(walletPali);
        when(externalBankService.transfer(eq(walletPali), eq(request), anyString()))
                .thenReturn(externalResult);
        when(externalResult.success()).thenReturn(true);

        doThrow(new RuntimeException("recovery log save fail"))
                .when(transferRecoverySupportService)
                .onExternalSuccessBeforePersist(userId, idempotencyKey, request, externalResult);

        assertThatThrownBy(() ->
                financeTransferService.transfer(userId, idempotencyKey, request)
        ).isInstanceOf(RuntimeException.class)
                .hasMessage("recovery log save fail");

        verify(transferPersistenceService, never()).persist(anyLong(), anyString(), any(), any());
    }

    @Test
    @DisplayName("DB 저장 실패 시 onPersistFailure가 호출되고 IllegalArgumentException이 발생한다")
    void transfer_fail_when_persist_throws() {
        ExternalTransferResultDto externalResult = mock(ExternalTransferResultDto.class);

        when(transferValidationService.validate(userId, request)).thenReturn(walletPali);
        when(externalBankService.transfer(eq(walletPali), eq(request), anyString()))
                .thenReturn(externalResult);
        when(externalResult.success()).thenReturn(true);
        doNothing().when(transferRecoverySupportService)
                .onExternalSuccessBeforePersist(userId, idempotencyKey, request, externalResult);

        when(transferPersistenceService.persist(userId, idempotencyKey, request, externalResult))
                .thenThrow(new RuntimeException("db save fail"));

        assertThatThrownBy(() ->
                financeTransferService.transfer(userId, idempotencyKey, request)
        ).isInstanceOf(IllegalArgumentException.class)
                .hasMessage("실패 예외 던지기");

        verify(transferRecoverySupportService).onPersistFailure(
                eq(userId),
                eq(idempotencyKey),
                eq(request),
                eq(externalResult),
                any(RuntimeException.class)
        );
        verify(transferRecoverySupportService, never()).onPersistSuccess(
                anyLong(), anyString(), any(), any()
        );
    }

    @Test
    @DisplayName("DB 저장 실패 후 onPersistFailure도 실패하면 복구 실패 예외가 원래 예외를 덮어쓴다")
    void transfer_fail_when_persist_failure_handler_also_throws() {
        ExternalTransferResultDto externalResult = mock(ExternalTransferResultDto.class);

        when(transferValidationService.validate(userId, request)).thenReturn(walletPali);
        when(externalBankService.transfer(eq(walletPali), eq(request), anyString()))
                .thenReturn(externalResult);
        when(externalResult.success()).thenReturn(true);

        when(transferPersistenceService.persist(userId, idempotencyKey, request, externalResult))
                .thenThrow(new RuntimeException("db save fail"));

        doThrow(new RuntimeException("recovery fail"))
                .when(transferRecoverySupportService)
                .onPersistFailure(eq(userId), eq(idempotencyKey), eq(request), eq(externalResult), any());

        assertThatThrownBy(() ->
                financeTransferService.transfer(userId, idempotencyKey, request)
        ).isInstanceOf(RuntimeException.class)
                .hasMessage("recovery fail");
    }


    @Test
    @DisplayName("DB 저장은 성공했지만 onPersistSuccess가 실패하면 전체 요청이 실패한다")
    void transfer_fail_when_on_persist_success_throws() {
        ExternalTransferResultDto externalResult = mock(ExternalTransferResultDto.class);
        TransferPersistResultDto persistResult = mock(TransferPersistResultDto.class);

        when(transferValidationService.validate(userId, request)).thenReturn(walletPali);
        when(externalBankService.transfer(eq(walletPali), eq(request), anyString()))
                .thenReturn(externalResult);
        when(externalResult.success()).thenReturn(true);
        when(transferPersistenceService.persist(userId, idempotencyKey, request, externalResult))
                .thenReturn(persistResult);

        doThrow(new RuntimeException("post persist hook fail"))
                .when(transferRecoverySupportService)
                .onPersistSuccess(userId, idempotencyKey, request, externalResult);

        assertThatThrownBy(() ->
                financeTransferService.transfer(userId, idempotencyKey, request)
        ).isInstanceOf(RuntimeException.class)
                .hasMessage("post persist hook fail");
    }


    @Test
    @DisplayName("persistResultDto.createdAt가 null이면 NPE가 발생한다")
    void transfer_fail_when_created_at_is_null() {
        ExternalTransferResultDto externalResult = mock(ExternalTransferResultDto.class);
        TransferPersistResultDto persistResult = mock(TransferPersistResultDto.class);

        when(transferValidationService.validate(userId, request)).thenReturn(walletPali);
        when(externalBankService.transfer(eq(walletPali), eq(request), anyString()))
                .thenReturn(externalResult);
        when(externalResult.success()).thenReturn(true);
        when(transferPersistenceService.persist(userId, idempotencyKey, request, externalResult))
                .thenReturn(persistResult);
        when(persistResult.transactionId()).thenReturn(1L);
        when(persistResult.currentBalance()).thenReturn(new BigDecimal("1000.00"));
        when(persistResult.createdAt()).thenReturn(null);

        assertThatThrownBy(() ->
                financeTransferService.transfer(userId, idempotencyKey, request)
        ).isInstanceOf(NullPointerException.class);
    }
}