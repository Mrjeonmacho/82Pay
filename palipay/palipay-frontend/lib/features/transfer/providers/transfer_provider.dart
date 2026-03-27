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

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ✅ [여기가 핵심!] 이 메서드가 반드시 클래스 내부 { } 안에 있어야 합니다.
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
      debugPrint('🧹 TransferProvider: 에러 메시지가 초기화되었습니다.');
    }
  }

  // --- [Step 1: 잔액 체크] ---
  Future<bool> checkBalance(int walletId, double amount) async {
    _setLoading(true);
    _errorMessage = null; // 시작 시 초기화

    try {
      final response = await _service.checkBalance(walletId, amount);
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
    _setLoading(true);
    _errorMessage = null; // 시작 시 초기화

    try {
      // 1. Validate
      final validateResult = await _service.validateTransfer(request);

      if (!validateResult.isSuccess || validateResult.data?.isValid == false) {
        final errors = validateResult.data?.validationErrors;
        if (errors != null && errors.isNotEmpty) {
          _errorMessage = errors.first.reason;
        } else {
          _errorMessage = validateResult.message ?? "계좌 정보를 확인해주세요.";
        }
        return null;
      }

      // 2. Execute
      final idempotencyKey = _uuid.v4();
      final result = await _service.executeTransfer(request, idempotencyKey);

      if (result.isSuccess && result.data != null) {
        _errorMessage = null; // 성공 시 에러 비우기
        return result.data;
      } else {
        _errorMessage = result.message ?? "송금 처리에 실패했습니다.";
        return null;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
