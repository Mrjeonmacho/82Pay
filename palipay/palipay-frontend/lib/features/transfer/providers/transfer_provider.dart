import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:palipay_app/features/transfer/models/transfer_model.dart';
import 'package:palipay_app/features/transfer/models/transfer_dto.dart';
import '../services/transfer_service.dart';
import '../../../core/utils/currency_input_formatter.dart';
import 'package:palipay_app/core/network/api_response.dart';

class TransferProvider extends ChangeNotifier {
  final TransferService _service;
  final _uuid = const Uuid();

  TransferProvider(this._service);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ✅ 예금주 조회 상태
  bool _isRecipientLoading = false;
  bool get isRecipientLoading => _isRecipientLoading;

  String? _recipientName;
  String? get recipientName => _recipientName;

  bool _isRecipientValidated = false;
  bool get isRecipientValidated => _isRecipientValidated;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// ✅ 에러 메시지 초기화
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
      debugPrint('🧹 TransferProvider: 에러 메시지가 초기화되었습니다.');
    }
  }

  /// ✅ 전체 상태 초기화 (송금 완료 후 혹은 재시작 시 호출)
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _isRecipientLoading = false;
    _recipientName = null;
    _isRecipientValidated = false;
    notifyListeners();
    debugPrint('🔄 TransferProvider: 모든 상태가 초기화되었습니다.');
  }

  // ✅ 계좌 입력 단계에서 호출할 초기화
  void resetRecipientInfo() {
    _isRecipientLoading = false;
    _recipientName = null;
    _isRecipientValidated = false;
    _errorMessage = null;
    notifyListeners();
  }

  // ✅ await 없이 시작해둘 예금주 조회
  Future<void> startRecipientValidation({
    required String otherBankCode,
    required String otherAccountNumber,
  }) async {
    _isRecipientLoading = true;
    _recipientName = null;
    _isRecipientValidated = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.validateRecipient(
        otherBankCode: otherBankCode,
        otherAccountNumber: otherAccountNumber,
      );

      if (!response.isSuccess || response.data == null) {
        _errorMessage = response.message ?? '계좌 검증에 실패했습니다.';
        return;
      }

      final data = response.data!;

      if (!data.isValid) {
        final errors = data.validationErrors ?? [];

        if (errors.isNotEmpty) {
          _errorMessage = errors.first.reason;
        } else {
          _errorMessage = data.message;
        }
        return;
      }

      _recipientName = data.accountName;
      _isRecipientValidated = true;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isRecipientLoading = false;
      notifyListeners();
    }
  }

  // --- [Step 1: 잔액 체크] ---
  Future<bool> checkBalance(int walletId, double amount) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _service.checkBalance(walletId, amount);
      if (!response.isSuccess || response.data == null) {
        _errorMessage = response.message ?? "잔액 조회에 실패했습니다.";
        return false;
      }

      if (!response.isSuccess || response.data == null) {
        _errorMessage = response.message ?? "잔액 조회에 실패했습니다.";
        return false;
      }

      final data = response.data!;
      if (data.isSufficient == false) {
        final formattedShortage = CurrencyInputFormatter.format(
          data.shortageAmount?.toInt() ?? 0,
        );
        _errorMessage = "잔액이 부족합니다. (부족금액: ₩$formattedShortage)";
        return false;
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // --- [Step 2 & 3: 송금 실행] ---
  Future<TransferExecuteResponse?> performTransfer(
    TransferRequest request,
  ) async {
    // 🚀 중복 클릭 방지 (이미 로딩 중이면 실행 안 함)
    if (_isLoading) {
      debugPrint('⚠️ TransferProvider: 이미 송금이 진행 중입니다.');
      return null;
    }

    _setLoading(true);
    _errorMessage = null; // 시작 시 이전 에러 초기화

    try {
      debugPrint('🔍 [Transfer] 1. 유효성 검사 시작');
      // 1. Validate (계좌 유효성 등 확인)
      final validateResult = await _service.validateTransfer(request);

      // 🔍 서버가 보내온 상세 에러 내용 출력
      debugPrint('❌ Validate Full Response: ${validateResult.data}');
      if (validateResult.data?.validationErrors != null) {
        for (var error in validateResult.data!.validationErrors!) {
          debugPrint('🚩 상세 사유: ${error.reason}, 필드: ${error.field}');
        }
      }
      // 1️⃣ 유효성 검사 자체가 실패했거나 계좌가 올바르지 않은 경우
      if (!validateResult.isSuccess || validateResult.data?.isValid == false) {
        _errorMessage =
            validateResult.data?.validationErrors?.first.reason ??
            validateResult.message ??
            "계좌 정보를 확인해주세요.";
        return null; // 여기서 종료
      }

      debugPrint('🚀 [Transfer] 2. 실제 송금 실행 (Idempotency Key 생성)');
      // 2. Execute (실제 송금 요청)
      // 중복 결제 방지를 위해 멱등성 키(UUID) 생성
      final idempotencyKey = _uuid.v4();
      final result = await _service.executeTransfer(request, idempotencyKey);

      if (result.isSuccess && result.data != null) {
        debugPrint('✅ [Transfer] 송금 성공!');
        _errorMessage = null;
        return result.data;
      } else {
        _errorMessage = result.message ?? "송금 처리에 실패했습니다.";
        debugPrint('❌ [Transfer] 송금 실패: $_errorMessage');
        return null;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('🚨 [Transfer] 예상치 못한 에러: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// 로딩 상태 설정 및 알림
  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }
}
