import 'package:flutter/material.dart';
import 'package:palipay_app/features/pin/models/pin_request_dto.dart';
import '../models/bank_account_model.dart';
import '../services/account_service.dart';

class AccountProvider extends ChangeNotifier {
  final AccountService _service = AccountService();

  BankAccount? _linkedAccount;
  bool _isLoading = false;

  bool get hasWallet => _linkedAccount != null;
  BankAccount? get linkedAccount => _linkedAccount;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> linkAccount({
    required Map<String, dynamic> requestData, 
    required String token,
  }) async {
    _setLoading(true);

    try {
      // 1. API 호출 (백엔드끼리 통신하여 계좌를 연동함)
      final response = await _service.linkAccount(
        accountData: requestData,
        token: token,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // [핵심] 서버의 응답(response.data)을 그대로 믿고 모델을 생성합니다.
        final data = response.data;

        _linkedAccount = BankAccount(
          walletId: data['walletId']?.toString() ?? '',
          bankCode: requestData['bankCode'],
          bankName: data['bankName'] ?? '연동계좌',
          accountNumber: data['accountNumber'] ?? requestData['accountNumber'],
          accountUsername: data['accountUsername'] ?? requestData['accountUsername'] ?? 'Unknown',
          moneyCode: requestData['moneyCode'] ?? 'USD',
          amount: (data['amount'] as num?)?.toInt() ?? 0, // 서버가 준 실시간 잔액!
        );
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('API 연동 실패: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 충전/환급 후 잔액을 업데이트하기 위한 메서드
  void updateBalance(int newBalance) {
    if (_linkedAccount != null) {
      _linkedAccount = _linkedAccount!.copyWith(amount: newBalance);
      notifyListeners();
    }
  }

  // [USER_ACCOUNT_002] 계좌 연동 해제
  Future<bool> unlinkAccount(String token) async {
    // walletId를 int로 변환하여 전송 (명세서 bigint 대응)
    if (_linkedAccount == null) return false;
    _setLoading(true);

    try {
      // TODO:
      // 서버 완전 연결 전 UI 테스트용 더미 처리
      await Future.delayed(const Duration(milliseconds: 250));

      _linkedAccount = null;
      notifyListeners();
      return true;

      // 실제 서버 붙으면 아래 로직으로 교체
      /*
      final int targetId = int.parse(_linkedAccount!.walletId);
      final response = await _service.unlinkAccount(targetId, token);

      if (response.statusCode == 200) {
        _linkedAccount = null;
        notifyListeners();
        return true;
      }
      return false;
      */
    } catch (e) {
      debugPrint('Error unlinking account: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // [USER_ACCOUNT_003] 핀(PIN) 번호 생성
  Future<bool> createPin({
    required String walletId,
    required String pinNumber,
    required String token,
  }) async {
    _setLoading(true);
    try {
      // 명세서 규격: walletId(bigint), pinNumber(String)

      // 요청 객체 만들기
      final request = PinCreateRequest(
        walletId: int.parse(walletId), // 명세서 bigint 대응
        pinNumber: pinNumber,
      );
      // 응답 객체 만들기
      final response = await _service.createPin(request, token);

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      // 409 CONFLICT: 이미 핀 번호가 존재함
      debugPrint('Error creating PIN: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // [USER_ACCOUNT_004] 핀(PIN) 번호 변경
  Future<bool> updatePin({
    required String walletId,
    required String oldPinNumber,
    required String newPinNumber,
    required String token,
  }) async {
    _setLoading(true);
    try {
      final request = PinUpdateRequest(
        walletId: int.parse(walletId), // 명세서 bigint 대응
        oldPinNumber: oldPinNumber,
        newPinNumber: newPinNumber,
      );
      // 명세서 규격: walletId, oldPinNumber, newPinNumber
      final response = await _service.updatePin(request, token);

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      // 400 BAD_REQUEST: 기존 핀 번호 불일치 등
      debugPrint('Error updating PIN: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
