import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
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
        final data = response.data;

        _linkedAccount = BankAccount(
          walletId: data['walletId']?.toString() ?? '',
          bankCode: requestData['bankCode'],
          bankName: data['bankName'] ?? '연동계좌',
          accountNumber: data['accountNumber'] ?? requestData['accountNumber'],
          accountUsername: data['accountUsername'] ?? requestData['accountUsername'] ?? 'Unknown',
          accountPassword: requestData['accountPassword'],
          moneyCode: requestData['moneyCode'] ?? 'USD',
          amount: (data['amount'] as num?)?.toInt() ?? 0,
        );
        
        notifyListeners();
        return "SUCCESS"; // 💡 성공
      }
      
      return "FAILED"; // 💡 일반적인 실패
    } catch (e) {
      // 💡 여기가 핵심입니다! 에러 원인을 분석합니다.
      debugPrint('API 연동 실패: $e');

      if (e is DioException) {
        // 1. 서버가 응답을 준 경우 (400, 401, 500 등)
        if (e.response != null) {
          int statusCode = e.response!.statusCode ?? 500;
          
          if (statusCode == 401 || statusCode == 400) {
            return "INVALID_PASSWORD"; // 💡 비밀번호 틀림
          } else if (statusCode >= 500) {
            return "SERVER_ERROR";    // 💡 서버 터짐
          }
        }
        
        // 2. 응답조차 없는 경우 (타임아웃 등)
        if (e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.connectionTimeout) {
          return "TIMEOUT";           // 💡 서버 대답 없음
        }
      }
      
      return "UNKNOWN_ERROR";
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
