import 'package:dio/dio.dart';
import 'package:palipay_app/core/constants/api_constants.dart';
import 'package:palipay_app/core/network/api_response.dart'; 
import 'package:palipay_app/features/transfer/models/transfer_model.dart';
import 'package:palipay_app/features/transfer/models/transfer_dto.dart';

import 'package:palipay_app/core/network/dio_client.dart';

class TransferService {
  final Dio _dio = DioClient().dio;

  TransferService();

  // 1단계: 잔액 체크 (FINANCE_CHECK_001)
  Future<ApiResponse<BalanceCheckResponse>> checkBalance(String walletId, double amount) async {
    try {
      final response = await _dio.post(
        ApiConstants.balanceCheck,
        data: {
          'walletId': walletId,
          'amount': amount,
        },
      );
      return ApiResponse.success(BalanceCheckResponse.fromJson(response.data['data']));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 2단계: 최종 검증 (FINANCE_TRANSFER_001)
  // Map 대신 TransferValidateResponse 모델을 사용하면 에러 목록 처리가 훨씬 쉬워집니다.
  Future<ApiResponse<TransferValidateResponse>> validateTransfer(TransferRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.transferValidate, 
        data: request.toJson()
      );
      return ApiResponse.success(TransferValidateResponse.fromJson(response.data['data']));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 3단계: 송금 실행 (FINANCE_TRANSFER_002)
  Future<ApiResponse<TransferExecuteResponse>> executeTransfer(
    TransferRequest request, 
    String idempotencyKey
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.transferExecute, // 상수명 확인: transfer -> transferExecute
        data: request.toJson(),
        options: Options(headers: {'idempotency-key': idempotencyKey}),
      );
      return ApiResponse.success(TransferExecuteResponse.fromJson(response.data['data']));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 공통 에러 핸들러 (명세서의 400, 422, 500 에러를 파싱)
  Exception _handleError(DioException e) {
    if (e.response != null) {
      final message = e.response?.data['message'] ?? "알 수 없는 오류가 발생했습니다.";
      // 팀장님, 여기서 명세서의 error.code(INSUFFICIENT_BALANCE 등)를 읽어서 커스텀 Exception을 던지면 좋습니다.
      return Exception(message);
    }
    return Exception("서버와 통신 중 네트워크 오류가 발생했습니다.");
  }
}