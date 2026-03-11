import 'package:dio/dio.dart';
import '../models/wallet_balance_model.dart';

class WalletService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://your-server-url.com',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    ),
  );

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
    final shortageAmount = isSufficient ? null : (amount - currentBalance).toInt();

    return WalletBalanceModel(
      currentBalance: currentBalance,
      isSufficient: isSufficient,
      requiredAmount: amount.toInt(),
      shortageAmount: shortageAmount,
      message: isSufficient ? '잔액이 충분합니다.' : '잔액이 부족합니다.',
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
        '/api/finance/balance/check',
        options: Options(
          headers: {
            'accesstoken': accessToken,
          },
        ),
        data: {
          'walletId': walletId,
          'amount': amount,
        },
      );

      if (response.data is! Map<String, dynamic>) {
        return const WalletBalanceModel(
          currentBalance: null,
          isSufficient: null,
          requiredAmount: null,
          shortageAmount: null,
          message: 'Invalid response format',
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
    } catch (e) {
      return const WalletBalanceModel(
        currentBalance: null,
        isSufficient: null,
        requiredAmount: null,
        shortageAmount: null,
        message: 'failed to load wallet balance',
      );
    }
  }
}