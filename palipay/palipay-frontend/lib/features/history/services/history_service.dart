import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:palipay_app/core/network/dio_client.dart';

class HistoryService {
  final Dio _dio = DioClient().dio;

  // 1. 거래 내역 목록 조회 (FINANCE_HISTORY_001) - 필터 로직 제거
  Future<Map<String, dynamic>> getTransactions({
    int page = 0,
    int size = 20,
    int? walletId,
    String? token,
  }) async {
    try {
      final response = await _dio.get(
        '/finance/transactions',
        queryParameters: {
          'page': page,
          'size': size,
          // category 관련 조건문 제거
          if (walletId != null && walletId != 0) 'walletId': walletId,
        },
        options: Options(headers: {'accesstoken': token ?? 'TEMP_TOKEN'}),
      );

      // 명세서상 response.data['data'] 내부에 items와 page 정보가 있음
      return response.data['data'];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 2. 특정 거래 상세 환산 정보 조회 (FINANCE_HISTORY_002)
  Future<Map<String, dynamic>> getTransactionCurrency(
    int transactionId,
    String targetCurrency, {
    String? token,
  }) async {
    try {
      final response = await _dio.get(
        '/finance/transactions/$transactionId/currency',
        queryParameters: {'targetCurrency': targetCurrency},
        options: Options(headers: {'accesstoken': token ?? 'TEMP_TOKEN'}),
      );

      return response.data['data'];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 공통 에러 핸들링
  String _handleError(DioException e) {
    // 서버에서 내려주는 에러 메시지가 있으면 우선 사용하고, 없으면 공통 메시지 출력
    return e.response?.data['message'] ?? 'error.network_issue'.tr();
  }
}
