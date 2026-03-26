import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // 중복 방지 키 생성을 위해 필요
import 'package:palipay_app/features/transfer/models/transfer_model.dart';
import 'package:palipay_app/features/transfer/models/transfer_dto.dart';
import '../services/transfer_service.dart';
import '../../../core/utils/currency_input_formatter.dart';
import 'package:palipay_app/core/network/api_response.dart';

class TransferProvider extends ChangeNotifier {
  final TransferService _service;
  final _uuid = const Uuid(); // 매번 생성하지 않도록 상수로 선언

  TransferProvider(this._service); // 외부에서 주입받는 방식이 테스트에 유리합니다.

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // --- [Step 1: 잔액 체크] ---
  Future<bool> checkBalance(String walletId, double amount) async {
    _setLoading(true);
    _errorMessage = null; // 에러 메시지 초기화
    try {
      final response = await _service.checkBalance(walletId, amount);

      // API 자체가 실패했거나 잔액이 부족한 경우 처리
      if (!response.isSuccess || response.data?.isSufficient == false) {
        final formattedShortage = CurrencyInputFormatter.format(
          response.data?.shortageAmount?.toInt() ?? 0,
        );
        _errorMessage =
            response.message ?? "잔액이 부족합니다. (부족금액: $formattedShortage)";
        return false;
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
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
    _errorMessage = null;

    try {
      // 1. 송금 전 최종 검증 (Validate)
      final validateResult = await _service.validateTransfer(request);
      if (validateResult.data?.isValid == false) {
        _errorMessage =
            validateResult.data?.validationErrors?.first.reason ?? "검증 실패";
        return null;
      }

      // 2. 실제 송금 실행 (Execute)
      // 중복 결제 방지를 위해 유니크한 키 생성 (Idempotency)
      final idempotencyKey = _uuid.v4();

      final result = await _service.executeTransfer(request, idempotencyKey);
      if (result.isSuccess && result.data != null) {
        return result.data; // 성공 시 영수증 데이터 반환
      } else {
        _errorMessage = result.message ?? "송금 처리에 실패했습니다.";
        return null;
      }
    } catch (e) {
      _errorMessage = e.toString();
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
