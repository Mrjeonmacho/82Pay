import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';

class HistoryService {
  // 실제 환경에서는 baseUrl을 환경 변수나 공통 설정에서 가져옵니다.
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));

  // 1. 거래 내역 목록 조회 (FINANCE_HISTORY_001)
  Future<Map<String, dynamic>> getTransactions({
    int page = 0,
    int size = 20,
    String? category,
    String? token, // 실제로는 Interceptor에서 처리하는 것을 권장합니다.
  }) async {
    try {
      final response = await _dio.get(
        '/api/finance/transactions',
        queryParameters: {
          'page': page,
          'size': size,
          if (category != null && category != 'All')
            'category': category.toUpperCase(),
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
        '/api/finance/transactions/$transactionId/currency',
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
    return e.response?.data['message'] ?? 'error.network_issue'.tr();
  }
}
