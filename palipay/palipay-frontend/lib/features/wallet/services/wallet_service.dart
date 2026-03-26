import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/api_constants.dart';
import '../models/wallet_model.dart';
import 'package:palipay_app/core/network/dio_client.dart';

class WalletService {
  // 💡 절대 여기 안에 final WalletService _service = WalletService(); 를 넣지 마세요!
  final Dio _dio = DioClient().dio;

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
      return WalletBalanceModel.empty().copyWith(message: 'error.network_issue'.tr());
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
    final response = await _dio.post('/finance/charges', data: {
      'walletId': walletId,
      'pinNumber': pinNumber,
      'accountCurrency': accountCurrency,
      'convertedAmount': convertedAmount,
      'amount': amount,
    });
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
    final response = await _dio.post('/finance/refunds', data: {
      'walletId': walletId,
      'pinNumber': pinNumber,
      'accountCurrency': accountCurrency,
      'convertedAmount': convertedAmount,
      'amount': amount,
    });
    return response.data;
  }

  /// 최대 환불 가능 금액 조회
  Future<Map<String, dynamic>> getMaxRefundable({required int walletId}) async {
    final response = await _dio.get('/finance/refunds/max', queryParameters: {'walletId': walletId});
    return response.data;
  }

  /// 환율 견적 조회
  Future<Map<String, dynamic>> getExchangeRateQuote({required String currency}) async {
    final response = await _dio.get('/finance/quote', queryParameters: {'currency': currency});
    return response.data;
  }
}