import 'package:flutter/material.dart';
import 'package:palipay_app/features/pin/models/pin_request_dto.dart';
import '../models/bank_account_model.dart';
import '../services/account_service.dart';

class AccountProvider extends ChangeNotifier {
  final AccountService _service = AccountService();

  // BankAccount? _linkedAccount; // 계좌 데이터
  // 테스트용 더미
  BankAccount? _linkedAccount = BankAccount(
    walletId: '1004',
    bankCode: '088',
    bankName: 'World',
    accountNumber: '110-482-039201',
    accountUsername: 'Ssafy Kim',
    moneyCode: 'USD',
    amount: 120000,
  );

  bool _isLoading = false;
  // _linkedAccount가 null이 아니면 true를 반환합니다.
  bool get hasWallet => _linkedAccount != null;

  BankAccount? get linkedAccount => _linkedAccount;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // [USER_ACCOUNT_001] 계좌 등록 및 연동
  Future<bool> linkAccount({
    required String walletId,
    required String bankCode,
    required String bankName, // UI 표시용
    required String accountNumber,
    required String accountUsername,
    required String moneyCode,
    required String token, // 인증 토큰
  }) async {
    _setLoading(true);

    try {
      // 명세서 규격에 맞춘 데이터 전송 (camelCase)
      final response = await _service.linkAccount({
        'walletId': walletId,
        'bankCode': bankCode,
        'accountNumber': accountNumber,
        'accountUsername': accountUsername,
        'moneyCode': moneyCode,
      }, token);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 성공 시 로컬 상태 업데이트
        _linkedAccount = BankAccount(
          walletId: walletId,
          bankCode: bankCode,
          bankName: bankName,
          accountNumber: accountNumber,
          accountUsername: accountUsername,
          moneyCode: moneyCode,
          amount: response.data['data']['walletId'], // 응답 데이터 구조 확인 필요
        );
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error linking account: $e');
      return false;
    } finally {
      _setLoading(false);
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

  // 테스트 다시 하고 싶을 때 더미 계좌 복구용
  void restoreDummyAccount() {
    _linkedAccount = BankAccount(
      walletId: '1004',
      bankCode: '088',
      bankName: 'World',
      accountNumber: '110-482-039201',
      accountUsername: 'Ssafy Kim',
      moneyCode: 'USD',
      amount: 120000,
    );
    notifyListeners();
  }
}
