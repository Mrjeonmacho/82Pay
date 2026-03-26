import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/api_constants.dart';
import '../models/wallet_model.dart';
import 'package:palipay_app/core/network/dio_client.dart';

class WalletService {
  // 💡 절대 여기 안에 final WalletService _service = WalletService(); 를 넣지 마세요!
  final Dio _dio = DioClient().dio;

  /// 🚀 NEW: 지갑 기본 정보 조회 (계좌번호, 이름, 잔액)
  Future<WalletInfoModel> fetchWalletInfo() async {
    // 👈 walletId 파라미터 제거!
    try {
      // 주소에 /api가 필요한지 확인해 보세요! (예: /api/finance/mywallet)
      final response = await _dio.get('/finance/mywallet');
      final responseData = response.data;
      final data = responseData['data'] as Map<String, dynamic>?;

      return WalletInfoModel(
        // 💾 중요: 서버가 주는 진짜 ID를 모델에 꼭 담아줘야 합니다.
        walletId: data?['walletId'] as int?,
        message: responseData['message'] as String?,
        accountNumber: data?['accountNumber'] as String?,
        accountUsername: data?['accountUsername'] as String?,
        amount: (data?['amount'] as num?)?.toDouble(),
      );
    } catch (e) {
      print('🚨 fetchWalletInfo 에러: $e');
      return WalletInfoModel.empty().copyWith(
        message: 'error.network_issue'.tr(),
      );
    }
  }

  /// 지갑 잔액 조회
  Future<WalletBalanceModel> fetchWalletBalance({
    required int walletId,
    required num amount,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.balanceCheck,
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
    );
    return response.data;
  }

  /// 최대 환불 가능 금액 조회
  Future<Map<String, dynamic>> getMaxRefundable({required int walletId}) async {
    final response = await _dio.get(
      '/finance/refunds/max',
      queryParameters: {'walletId': walletId},
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
