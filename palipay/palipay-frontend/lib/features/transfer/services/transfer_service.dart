import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:palipay_app/core/constants/api_constants.dart';
import 'package:palipay_app/core/network/api_response.dart';
import 'package:palipay_app/features/transfer/models/transfer_model.dart';
import 'package:palipay_app/features/transfer/models/transfer_dto.dart';
import 'package:palipay_app/core/network/dio_client.dart';

class TransferService {
  final Dio _dio = DioClient().dio;

  TransferService();

  // 1단계: 잔액 체크 (FINANCE_CHECK_001)
  // 🚀 walletId를 명세서(Bigint)에 맞춰 int로 변경
  Future<ApiResponse<BalanceCheckResponse>> checkBalance(
    int walletId,
    double amount,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.balanceCheck,
        data: {'walletId': walletId, 'amount': amount},
      );
      return ApiResponse.success(
        BalanceCheckResponse.fromJson(response.data['data']),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 2단계: 최종 검증 (FINANCE_TRANSFER_001)
  Future<ApiResponse<TransferValidateResponse>> validateTransfer(
    TransferRequest request,
  ) async {
    try {
      // 🚀 로그를 찍어서 실제로 'currency'가 들어있는지 확인해보세요!
      debugPrint('📦 검증 요청 데이터: ${request.toJson()}');

      final response = await _dio.post(
        '/finance/external-accounts/validate', // 📍 경로가 바뀌었네요!
        data: request.toJson(),
      );

      // ✅ [Response Success Log]
      debugPrint('✅ [API Response] 200 OK');
      debugPrint('📩 Data: ${response.data}'); // 서버가 준 날것의 JSON
      debugPrint('────────────────────────────────────────────');

      // 🚀 [수정] 데이터가 null인지 확인하고 안전하게 전달
      final rawData = response.data['data'];
      return ApiResponse.success(
        TransferValidateResponse.fromJson(
          response.data as Map<String, dynamic>,
        ),
      );
    } on DioException catch (e) {
      // ❌ [API Error Log]
      debugPrint(
        '❌ [API Error] ${e.response?.statusCode} | ${e.requestOptions.path}',
      );
      debugPrint(
        '💣 Error Data: ${e.response?.data}',
      ); // 👈 여기가 "왜 안 되는지" 알려주는 핵심!
      debugPrint('❗ Message: ${e.message}');
      debugPrint('────────────────────────────────────────────');
      throw _handleError(e);
    }
  }

  // 3단계: 송금 실행 (FINANCE_TRANSFER_002)
  Future<ApiResponse<TransferExecuteResponse>> executeTransfer(
    TransferRequest request,
    String idempotencyKey,
  ) async {
    try {
      final response = await _dio.post(
        '/finance/transfers',
        data: request.toJson(),
        options: Options(
          headers: {
            // 🚀 명세서의 소문자 표기(idempotency-key) 준수
            'idempotency-key': idempotencyKey,
          },
        ),
      );
      return ApiResponse.success(
        TransferExecuteResponse.fromJson(response.data['data']),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 🚀 공통 에러 핸들러 (409 Conflict 및 비즈니스 에러 코드 파싱 강화)
  Exception _handleError(DioException e) {
    if (e.response != null) {
      final responseData = e.response?.data;
      final String message = responseData['message'] ?? "알 수 없는 오류가 발생했습니다.";

      // 명세서의 409 Conflict (중복 요청) 처리
      if (e.response?.statusCode == 409) {
        return Exception("이미 처리 중인 거래입니다. 잠시 후 내역을 확인해주세요.");
      }

      // 💡 [참고] 명세서의 error.code (예: INSUFFICIENT_BALANCE) 추출 로직
      final String? errorCode = responseData['error']?['code'];
      if (errorCode != null) {
        debugPrint('🚨 [Business Error] Code: $errorCode, Message: $message');
        // 필요 시 여기서 errorCode에 따른 한글 메시지 분기 처리를 하면 더 좋습니다.
      }

      return Exception(message);
    }
    return Exception("서버와 통신 중 네트워크 오류가 발생했습니다.");
  }
}
