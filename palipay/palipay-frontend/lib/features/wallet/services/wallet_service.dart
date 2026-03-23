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
        ApiConstants.accountBalance, // [수정] 상수 사용
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
}
