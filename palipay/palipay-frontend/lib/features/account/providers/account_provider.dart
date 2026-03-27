import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:palipay_app/core/providers/user_provider.dart';
import 'package:palipay_app/features/pin/models/pin_request_dto.dart';
import 'package:palipay_app/features/wallet/services/wallet_service.dart';
import '../models/bank_account_model.dart';
import '../services/account_service.dart';
import '../../../core/constants/bank_constants.dart';

class AccountProvider extends ChangeNotifier {
  final AccountService _service = AccountService();
  final WalletService _walletService = WalletService();

  BankAccount? _linkedAccount;
  bool _isLoading = false;
  String? _walletId;

  bool get hasWallet =>
      _linkedAccount != null && _linkedAccount!.accountNumber.isNotEmpty;
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
    debugPrint('🌐 [API Request] 계좌 삭제 시도');

    try {
      final int targetId = int.parse(_linkedAccount!.walletId);
      final response = await _service.unlinkAccount(targetId, token);

      // 🚀 2. 응답 로그: 서버에서 뭐라고 답변하는지 확인
      debugPrint('✅ [API Response] Status Code: ${response.statusCode}');
      debugPrint('📄 Data: ${response.data}');

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

  /// [USER_ACCOUNT_005] 서버에서 최신 지갑/계좌 정보 가져오기
  Future<void> refreshWalletInfo(BuildContext context) async {
    final userCountry = context.read<UserProvider>().countryCode ?? 'US';
    _isLoading = true;
    notifyListeners();

    try {
      // 1. 서비스 호출
      final walletInfo = await _walletService.fetchWalletInfo();
      print("walletInfo: $walletInfo");
      // 2. 데이터가 정상적으로 왔는지 확인 (walletId가 있다면 지갑이 있는 것)
      if (walletInfo.walletId != null) {
        final List<Map<String, dynamic>> countryBanks = BankConstants.getBanks(
          userCountry,
        );
        final String currency = BankConstants.getDefaultCurrency(userCountry);

        final bankName = BankConstants.getBankName(
          userCountry,
          walletInfo.bankCode ?? '',
        );

        _linkedAccount = BankAccount(
          walletId: walletInfo.walletId.toString(),
          bankName: bankName,
          accountNumber: walletInfo.accountNumber ?? '',
          accountUsername: walletInfo.accountUsername ?? '',
          amount: walletInfo.amount?.toInt() ?? 0,
          // password나 bankCode는 보안상 서버에서 안 오므로 기존 값을 유지하거나 비워둠
          accountPassword: _linkedAccount?.accountPassword ?? '',
          bankCode: _linkedAccount?.bankCode ?? '',
          moneyCode: currency,
        );
      } else {
        _linkedAccount = null; // 지갑 정보가 없으면 null 처리
      }
    } catch (e) {
      debugPrint('🚨 지갑 정보 갱신 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
