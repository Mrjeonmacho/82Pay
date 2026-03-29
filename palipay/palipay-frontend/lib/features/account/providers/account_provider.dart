// lib/features/account/providers/account_provider.dart

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

  // walletId의 단일 출처 — UserProvider에서 완전히 이관
  String? get walletId => _linkedAccount?.walletId;

  bool get hasWallet =>
      _linkedAccount != null && _linkedAccount!.accountNumber.isNotEmpty;
  BankAccount? get linkedAccount => _linkedAccount;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// [USER_ACCOUNT_001] 계좌 연동
  Future<String> linkAccount({
    required Map<String, dynamic> requestData,
    required String token,
  }) async {
    _setLoading(true);

    try {
      final response = await _service.linkAccount(accountData: requestData);
      debugPrint('🔍 연동 응답: ${response.data}'); // 추가

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 변경 전
        // final data = response.data['data'];
        // _linkedAccount = BankAccount(
        //   walletId: data['walletId']!,

        // 변경 후 — data 키 없이 바로 참조
        final responseData = response.data;

        _linkedAccount = BankAccount(
          walletId: responseData['walletId'].toString(),
          bankCode: requestData['bankCode'],
          bankName: requestData['bankName'] ?? 'Pali Account',
          accountNumber: requestData['accountNumber'],
          accountUsername: requestData['accountUsername'] ?? 'Unknown',
          accountPassword: requestData['accountPassword'],
          moneyCode: requestData['moneyCode'] ?? 'KRW',
          amount: 0,
        );

        notifyListeners();
        return 'SUCCESS';
      }

      return 'FAILED';
    } catch (e) {
      debugPrint('🚨 계좌 연동 실패: $e');

      if (e is DioException && e.response != null) {
        final statusCode = e.response!.statusCode ?? 500;

        if (statusCode == 400 || statusCode == 401) return 'INVALID_PASSWORD';
        if (statusCode == 409) return 'ALREADY_LINKED';
        if (statusCode >= 500) return 'SERVER_ERROR';
      }

      if (e is DioException &&
          (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout)) {
        return 'TIMEOUT';
      }

      return 'UNKNOWN_ERROR';
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

  /// [USER_ACCOUNT_002] 계좌 연동 해제
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

  /// [USER_ACCOUNT_003] PIN 번호 생성
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

  /// [USER_ACCOUNT_004] PIN 번호 변경
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
  /// 로그인 직후 및 앱 재시작 시 호출 — walletId 확정의 단일 진입점
  Future<void> refreshWalletInfo(BuildContext context) async {
    final userCountry = context.read<UserProvider>().countryCode ?? 'US';
    _isLoading = true;
    notifyListeners();

    try {
      final walletInfo = await _walletService.fetchWalletInfo();

      if (walletInfo.walletId != null) {
        final String currency = BankConstants.getDefaultCurrency(userCountry);
        final String bankName = BankConstants.getBankName(
          userCountry,
          walletInfo.bankCode ?? '',
        );

        _linkedAccount = BankAccount(
          walletId: walletInfo.walletId.toString(),
          bankName: bankName,
          accountNumber: walletInfo.accountNumber ?? '',
          accountUsername: walletInfo.accountUsername ?? '',
          amount: walletInfo.amount?.toInt() ?? 0,
          accountPassword: _linkedAccount?.accountPassword ?? '',
          bankCode: _linkedAccount?.bankCode ?? '',
          moneyCode: currency,
        );
      } else {
        _linkedAccount = null;
      }
    } catch (e) {
      debugPrint('🚨 지갑 정보 갱신 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
