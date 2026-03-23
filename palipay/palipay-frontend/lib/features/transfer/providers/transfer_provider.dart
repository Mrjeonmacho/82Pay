import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // 중복 방지 키 생성을 위해 필요
import 'package:palipay_app/features/transfer/models/transfer_model.dart';
import 'package:palipay_app/features/transfer/models/transfer_dto.dart';
import '../services/transfer_service.dart';


class TransferProvider extends ChangeNotifier {
  final TransferService _service;
  
  TransferProvider(this._service); // 외부에서 주입받는 방식이 테스트에 유리합니다.

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // --- [Step 1: 잔액 체크] ---
  Future<bool> checkBalance(String walletId, double amount) async {
    _setLoading(true);
    try {
      final response = await _service.checkBalance(walletId, amount);
      if (response.data?.isSufficient == false) {
        _errorMessage = "잔액이 부족합니다. (부족금액: ${response.data?.shortageAmount})";
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
  Future<TransferExecuteResponse?> performTransfer(TransferRequest request) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // 1. 송금 전 최종 검증 (Validate)
      final validateResult = await _service.validateTransfer(request);
      if (validateResult.data?.isValid == false) {
        _errorMessage = validateResult.data?.validationErrors?.first.reason ?? "검증 실패";
        return null;
      }

      // 2. 실제 송금 실행 (Execute)
      // 중복 결제 방지를 위해 유니크한 키 생성 (Idempotency)
      final idempotencyKey = const Uuid().v4(); 
      
      final result = await _service.executeTransfer(request, idempotencyKey);
      return result.data; // 성공 시 결과(영수증) 데이터 반환
      
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