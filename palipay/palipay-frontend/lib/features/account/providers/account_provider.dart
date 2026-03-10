import 'package:flutter/material.dart';
import '../models/bank_account_model.dart';
import '../services/account_service.dart'; // 서비스 파일 임포트 확인

class AccountProvider extends ChangeNotifier {
  // 서비스 클래스 인스턴스화
  final AccountService _service = AccountService();

  // 1인 1계좌 상태 관리
  BankAccount? _linkedAccount;
  bool _isLoading = false;

  BankAccount? get linkedAccount => _linkedAccount;
  bool get isLoading => _isLoading;

  // 로딩 상태 제어 헬퍼
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // [USER_ACCOUNT_001] 계좌 등록/연동
  // 뷰(View)에서 호출할 때 이 이름과 똑같아야 함
  Future<bool> linkAccount({
    required String bankName,
    required String accountNumber,
    required String countryCode,
    required String password, // 인자로만 받음
  }) async {
    _setLoading(true);

    try {
      // 실제 API 통신 (서비스 호출)
      final response = await _service.linkAccount({
        'bank_name': bankName,
        'account_number': accountNumber,
        'country_code': countryCode,
        'account_password': password,
      });

      // 서버 응답이 성공적일 때 상태 업데이트
      if (response.statusCode == 200 || response.statusCode == 201) {
        _linkedAccount = BankAccount(
          bankId: response.data['bank_id'] ?? DateTime.now().toString(),
          bankName: bankName,
          accountNumber: accountNumber,
          amount: response.data['amount'] ?? 1000000, // ERD 기준 amount 사용
          countryCode: countryCode,
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

  // [USER_ACCOUNT_002] 계좌 삭제
  Future<bool> unlinkAccount() async {
    if (_linkedAccount == null) return false;
    _setLoading(true);

    try {
      // 서비스 호출: /api/users/accounts/{accountId}
      final response = await _service.unlinkAccount(_linkedAccount!.bankId);

      if (response.statusCode == 200) {
        _linkedAccount = null;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error unlinking account: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
