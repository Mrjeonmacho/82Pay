import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/config/env_config.dart';
import '../../../core/constants/api_constants.dart';
import '../models/wallet_model.dart';

import 'package:palipay_app/core/network/dio_client.dart';

class WalletService {
  final Dio _dio = DioClient().dio;

  /// -----------------------------
  /// 1. 지금 화면 확인용 더미 데이터
  /// -----------------------------
  Future<WalletBalanceModel> fetchWalletBalanceDummy({
    required int walletId,
    required num amount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // 더미 응답 예시
    const currentBalance = 500000;

    final isSufficient = amount <= currentBalance;
    final shortageAmount = isSufficient
        ? null
        : (amount - currentBalance).toInt();

    return WalletBalanceModel(
      currentBalance: currentBalance,
      isSufficient: isSufficient,
      requiredAmount: amount.toInt(),
      shortageAmount: shortageAmount,
      // message: isSufficient ? 'wallet.error.sufficient_balance'.tr() : 'wallet.error.insufficient_balance'.tr(),
    );
  }

  /// -----------------------------------------
  /// 2. 나중에 서버 연결할 때 사용할 실제 API 호출
  /// -----------------------------------------
  Future<WalletBalanceModel> fetchWalletBalance({
    required String accessToken,
    required int walletId,
    required num amount,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.balanceCheck, // [수정] 상수 사용
        options: Options(headers: {'accesstoken': accessToken}),
        data: {'walletId': walletId, 'amount': amount},
      );

      if (response.data is! Map<String, dynamic>) {
        return WalletBalanceModel(
          currentBalance: null,
          isSufficient: null,
          requiredAmount: null,
          shortageAmount: null,
          message: 'error.invalid_response'.tr(),
        );
      }

      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>?;

      return WalletBalanceModel(
        message: responseData['message'] as String?,
        isSufficient: data?['isSufficient'] as bool?,
        currentBalance: (data?['currentBalance'] as num?)?.toInt(),
        requiredAmount: (data?['requiredAmount'] as num?)?.toInt(),
        shortageAmount: (data?['shortageAmount'] as num?)?.toInt(),
      );
    } on DioException catch (e) {
      return WalletBalanceModel(
        currentBalance: null,
        isSufficient: null,
        requiredAmount: null,
        shortageAmount: null,
        message: e.response?.data?['message'] ?? 'error.network_issue'.tr(),
      );
    }
  }

  // [FINANCE_CHARGE_002] 지갑 충전 (POST /api/finance/charges)
  Future<Map<String, dynamic>> chargeWallet({
    required int walletId,
    required String pinNumber,
    required String accountCurrency, // 사용자 통화 (결제 시 사용될 통화)
    required num convertedAmount,    // 충전 반영 통화 금액 (KRW 등)
    required num amount,             // 외국 은행 출금액 (해당 통화 기준)
  }) async {
    try {
      final response = await _dio.post(
        '/finance/charges',
        data: {
          'walletId': walletId,
          'pinNumber': pinNumber,
          'accountCurrency': accountCurrency, // 외화
          'convertedAmount': convertedAmount, // 원화
          'amount': amount,
        },
      );
      return response.data; // 명세에 나온대로 data(message, data)를 포함한 map 반환
    } catch (e) {
      rethrow;
    }
  }

  // [FINANCE_REFUND_002] 지갑 환급 (POST /api/finance/refunds)
  Future<Map<String, dynamic>> refundWallet({
    required int walletId,
    required String pinNumber,
    required String accountCurrency, // 사용자 통화
    required num convertedAmount,    // 환급될 통화 금액 (KRW 기준)
    required num amount,             // 외국 계좌로 입금될 통화 금액
  }) async {
    try {
      final response = await _dio.post(
        '/finance/refunds',
        data: {
          'walletId': walletId,
          'pinNumber': pinNumber,
          'accountCurrency': accountCurrency,
          'convertedAmount': convertedAmount,
          'amount': amount,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // [FINANCE_REFUND_001] 최대 환불 가능 금액 조회 (GET /api/finance/refunds/max)
  Future<Map<String, dynamic>> getMaxRefundable({
    required int walletId,
  }) async {
    try {
      // API 명세서에 Body로 요구되어 있으나 Http GET 메서드이므로 data에 객체 전달
      final response = await _dio.get(
        '/finance/refunds/max',
        data: {
          'walletId': walletId,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // [FINANCE_CHARGE_001] 환율 견적 조회 (GET /api/finance/quote)
  Future<Map<String, dynamic>> getExchangeRateQuote({
    required String currency,
  }) async {
    try {
      final response = await _dio.get(
        '/finance/quote',
        data: {
          'currency': currency,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
