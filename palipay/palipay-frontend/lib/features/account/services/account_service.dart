import 'package:dio/dio.dart';
import 'package:palipay_app/features/pin/models/pin_request_dto.dart';
import 'package:palipay_app/core/config/env_config.dart';
import 'package:palipay_app/core/network/dio_client.dart';

class AccountService {
  final Dio _dio = DioClient().dio;

  // 1. 계좌 등록 (POST /api/users/accounts)
  Future<Response> linkAccount({
    required Map<String, dynamic> accountData,
  }) async {
    try {
      const String path = '/wallet/accounts';
      print('📡 최종 전송 URL: ${_dio.options.baseUrl}$path');
      return await _dio.post(path, data: accountData);
    } on DioException catch (e) {
      print('❌ 서버 응답 에러 코드: ${e.response?.statusCode}');
      print('❌ 서버 응답 내용: ${e.response?.data}');
      rethrow;
    }
  }

  // 2. 계좌 연동 해제(삭제) (DELETE /api/users/accounts/{accountId})
  Future<Response> unlinkAccount(int walletId, String token) async {
    try {
      // Path Variable로 walletId(bigint) 전달
      return await _dio.delete(
        '/wallet/accounts/$walletId',
        options: Options(headers: {'accessToken': token}),
      );
    } catch (e) {
      rethrow;
    }
  }

  // 3. PIN 번호 생성/수정 (POST, PATCH)
  Future<Response> createPin(PinCreateRequest request, String token) async {
    try {
      return await _dio.post(
        '/wallet/pin',
        data: request.toJson(), // 모델이 스스로 JSON 변환          },
        options: Options(headers: {'accessToken': token}),
      );
    } catch (e) {
      rethrow;
    }
  }

  // 4. PIN 번호 변경 (USER_ACCOUNT_004)
  Future<Response> updatePin(PinUpdateRequest request, String token) async {
    try {
      return await _dio.patch(
        '/wallet/pin',
        data: request.toJson(), // 모델이 스스로 JSON 변환
        options: Options(headers: {'accessToken': token}),
      );
    } catch (e) {
      rethrow;
    }
  }
}
