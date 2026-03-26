// lib/features/wallet/services/wallet_service.dart

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/wallet_model.dart';
import 'package:palipay_app/core/network/dio_client.dart';

class WalletService {
  final Dio _dio = DioClient().dio;

  /// 🚀 지갑 기본 정보 조회 (bankCode 매핑 포함)
  Future<WalletInfoModel> fetchWalletInfo() async {
    try {
      // 📍 경로 확인: /api/finance/mywallet
      final response = await _dio.get('/wallet/mywallet');
      final responseData = response.data;
      final data = responseData['data'] as Map<String, dynamic>?;

      return WalletInfoModel(
        walletId: data?['walletId'] as int?,
        accountNumber: data?['accountNumber'] as String?,
        accountUsername: data?['accountUsername'] as String?,
        // ⭐ 바로 이 부분입니다! 서버 JSON의 'bankCode'를 모델에 전달
        bankCode: data?['bankCode'] as String?,
        amount: (data?['amount'] as num?)?.toDouble(),
        message: responseData['message'] as String?,
      );
    } catch (e) {
      print('🚨 fetchWalletInfo 에러: $e');
      return WalletInfoModel.empty().copyWith(
        message: 'error.network_issue'.tr(),
      );
    }
  }

  /// 지갑 잔액 조회 및 부족 여부 체크
  Future<WalletBalanceModel> fetchWalletBalance({
    required int walletId,
    required num amount,
  }) async {
    try {
      final response = await _dio.post(
        '/finance/balance/check',
        data: {'walletId': walletId, 'amount': amount},
      );
      final responseData = response.data;
      final data = responseData['data'] as Map<String, dynamic>?;

      return WalletBalanceModel(
        message: responseData['message'] as String?,
        isSufficient: data?['isSufficient'] as bool?,
        currentBalance: (data?['currentBalance'] as num?)?.toInt(),
        requiredAmount: (data?['requiredAmount'] as num?)?.toInt(),
        shortageAmount: (data?['shortageAmount'] as num?)?.toInt(),
      );
    } catch (e) {
      return WalletBalanceModel.empty().copyWith(
        message: 'error.network_issue'.tr(),
      );
    }
  }

  /// 지갑 충전
  Future<Map<String, dynamic>> chargeWallet({
    required int walletId,
    required String pinNumber,
    required String accountCurrency,
    required num convertedAmount,
    required num amount,
  }) async {
    final response = await _dio.post(
      '/finance/charges',
      data: {
        'walletId': walletId,
        'pinNumber': pinNumber,
        'accountCurrency': accountCurrency,
        'convertedAmount': convertedAmount,
        'amount': amount,
      },
      options: Options(
        headers: {
          'Idempotency-Key': 'charge_${DateTime.now().millisecondsSinceEpoch}',
        },
      ),
    );
    return response.data;
  }

  /// 지갑 환급
  Future<Map<String, dynamic>> refundWallet({
    required int walletId,
    required String pinNumber,
    required String accountCurrency,
    required num convertedAmount,
    required num amount,
  }) async {
    final response = await _dio.post(
      '/finance/refunds',
      data: {
        'walletId': walletId,
        'pinNumber': pinNumber,
        'accountCurrency': accountCurrency,
        'convertedAmount': convertedAmount,
        'amount': amount,
      },
      options: Options(
        headers: {
          'Idempotency-Key': 'refund_${DateTime.now().millisecondsSinceEpoch}',
        },
      ),
    );
    return response.data;
  }

  /// 환율 견적 조회
  Future<Map<String, dynamic>> getExchangeRateQuote({
    required String currency,
  }) async {
    final response = await _dio.get(
      '/finance/quote',
      queryParameters: {'currency': currency},
    );
    return response.data;
  }
}
