import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:palipay_app/core/network/dio_client.dart';
import 'package:flutter/foundation.dart';

class HistoryService {
  final Dio _dio = DioClient().dio;

  /// 1. 거래 내역 목록 조회 (FINANCE_HISTORY_001)
  Future<Map<String, dynamic>> getTransactions({
    int? walletId,
    String? category,
    int page = 0,
    int size = 20,
    String? from,
    String? to,
  }) async {
    try {
      debugPrint('🛠️ [Service] 전달받은 walletId: $walletId');
      // 🚀 [포인트 1] 명세서가 GET + Body(JSON)를 요구함
      // Dio의 get은 기본적으로 body를 보내지 않으므로, 'data' 옵션을 강제로 사용해야 합니다.
      final response = await _dio.get(
        '/finance/transactions',
        options: Options(
          method: 'GET', // GET 방식 유지
          contentType: 'application/json; charset=UTF-8', // 명세서 준수
        ),
        queryParameters: {
          if (walletId != null && walletId != 0) 'walletId': walletId,
          if (from != null) 'from': from,
          if (to != null) 'to': to,
          if (category != null) 'category': category,
          'page': page,
          'size': size,
        },
      );

      debugPrint('📩 [History API] 응답 데이터: ${response.data}');

      // 🚀 [포인트 3] 응답 구조: { "message": "...", "data": { "items": [...], "page": {...} } }
      // 명세서 예시대로라면 response.data['data']에 접근하는 것이 맞습니다.
      if (response.data != null && response.data['data'] != null) {
        return response.data['data'];
      }

      return response.data; // 만약 data 계층이 없다면 전체 반환
    } on DioException catch (e) {
      debugPrint(
        '🚨 History API 에러: ${e.response?.statusCode} | ${e.response?.data}',
      );
      throw _handleError(e);
    }
  }

  /// 2. 특정 거래 상세 환산 정보 조회 (FINANCE_HISTORY_002)
  Future<Map<String, dynamic>> getTransactionCurrency({
    required int transactionId,
    required String targetCurrency, // 예: USD, JPY
    String? sourceCurrency, // 기본값 KRW (선택사항)
  }) async {
    try {
      // 🚀 명세서 URI: /api/finance/transactions/{transactionId}/currency
      final response = await _dio.get(
        '/finance/transactions/$transactionId/currency',
        queryParameters: {
          'targetCurrency': targetCurrency,
          if (sourceCurrency != null) 'sourceCurrency': sourceCurrency,
        },
      );

      // 🚀 응답 데이터 내의 'data' 계층 반환
      return response.data['data'];
    } on DioException catch (e) {
      debugPrint('🚨 FINANCE_HISTORY_002 에러: ${e.response?.statusCode}');
      throw _handleError(e);
    }
  }

  /// 공통 에러 핸들링
  String _handleError(DioException e) {
    if (e.response != null && e.response?.data is Map) {
      return e.response?.data['message'] ?? 'error.network_issue'.tr();
    }
    return 'error.network_issue'.tr();
  }
}
