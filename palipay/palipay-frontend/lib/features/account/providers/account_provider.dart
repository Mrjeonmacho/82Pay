import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:palipay_app/features/pin/models/pin_request_dto.dart';
import '../models/bank_account_model.dart';
import '../services/account_service.dart';

class AccountProvider extends ChangeNotifier {
  final AccountService _service = AccountService();

  BankAccount? _linkedAccount;
  bool _isLoading = false;
  String? _walletId;

  bool get hasWallet => _linkedAccount != null;
  BankAccount? get linkedAccount => _linkedAccount;
  bool get isLoading => _isLoading;
  String? get walletId => _walletId;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// [USER_ACCOUNT_001] 계좌 연동 (실제 서버 통신)
  Future<String> linkAccount({
    required Map<String, dynamic> requestData,
    required String token,
  }) async {
    _setLoading(true);

    try {
      final response = await _service.linkAccount(
        accountData: requestData,
        token: token,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data']; // 서버 응답 구조에 맞게 수정

        _linkedAccount = BankAccount(
          walletId: data['walletId']!,
          bankCode: requestData['bankCode'],
          bankName: data['bankName'] ?? 'Pali Account',
          accountNumber: data['accountNumber'] ?? requestData['accountNumber'],
          accountUsername: data['accountUsername'] ?? 'Unknown',
          accountPassword: requestData['accountPassword'],
          moneyCode: data['moneyCode'] ?? requestData['moneyCode'] ?? 'KRW',
          amount: (data['amount'] as num?)?.toInt() ?? 0,
        );

        _walletId = _linkedAccount?.walletId;

        notifyListeners();
        return "SUCCESS";
      }

      return "FAILED";
    } catch (e) {
      debugPrint('🚨 계좌 연동 실패: $e');

      if (e is DioException) {
        if (e.response != null) {
          int statusCode = e.response!.statusCode ?? 500;

          // 서버에서 정의한 에러 코드에 따라 분기
          if (statusCode == 401 || statusCode == 400) {
            return "INVALID_PASSWORD"; // 비밀번호가 틀렸거나 잘못된 요청
          } else if (statusCode == 409) {
            return "ALREADY_LINKED"; // 이미 연동된 계좌
          } else if (statusCode >= 500) {
            return "SERVER_ERROR"; // 서버 내부 에러
          }
        }

        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          return "TIMEOUT";
        }
      }

      return "UNKNOWN_ERROR";
    } finally {
      _setLoading(false);
    }
  }

  /// 충전/환급 후 잔액 동기화
  void updateBalance(int newBalance) {
    if (_linkedAccount != null) {
      _linkedAccount = _linkedAccount!.copyWith(amount: newBalance);
      notifyListeners();
    }
  }

  /// [USER_ACCOUNT_002] 계좌 연동 해제 (실제 서버 통신)
  Future<bool> unlinkAccount(String token) async {
    if (_linkedAccount == null) return false;
    _setLoading(true);

    try {
      final int targetId = int.parse(_linkedAccount!.walletId);
      final response = await _service.unlinkAccount(targetId, token);

      if (response.statusCode == 200 || response.statusCode == 204) {
        _linkedAccount = null;
        _walletId = null;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('🚨 계좌 해제 실패: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// [USER_ACCOUNT_003] 핀(PIN) 번호 생성
  Future<bool> createPin({
    required String walletId,
    required String pinNumber,
    required String token,
  }) async {
    _setLoading(true);
    try {
      final request = PinCreateRequest(
        walletId: int.parse(walletId),
        pinNumber: pinNumber,
      );
      final response = await _service.createPin(request, token);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('🚨 PIN 생성 실패: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// [USER_ACCOUNT_004] 핀(PIN) 번호 변경
  Future<bool> updatePin({
    required String walletId,
    required String oldPinNumber,
    required String newPinNumber,
    required String token,
  }) async {
    _setLoading(true);
    try {
      final request = PinUpdateRequest(
        walletId: int.parse(walletId),
        oldPinNumber: oldPinNumber,
        newPinNumber: newPinNumber,
      );
      final response = await _service.updatePin(request, token);

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('🚨 PIN 변경 실패: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
