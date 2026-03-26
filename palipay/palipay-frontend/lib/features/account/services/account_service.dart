import 'package:dio/dio.dart';
import 'package:palipay_app/features/pin/models/pin_request_dto.dart';
import 'package:palipay_app/core/config/env_config.dart';
import 'package:palipay_app/core/network/dio_client.dart';

class AccountService {

  final Dio _dio = DioClient().dio;

  // 1. 계좌 등록 (POST /api/users/accounts)
  Future<Response> linkAccount({
  required Map<String, dynamic> accountData,
  required String token,
}) async {
  try {
    const String path = '/wallet/accounts'; // 👈 백엔드와 100% 일치해야 함
    
    // [디버깅] 진짜 어디로 쏘는지 터미널에서 눈으로 확인합시다.
    print('📡 최종 전송 URL: ${_dio.options.baseUrl}$path');

    final response = await _dio.post(
      path,
      data: accountData,
      options: Options(
        headers: {
          'accesstoken': token, 
        },
      ),
    );
    return response;
  } on DioException catch (e) {
    // 404 에러 시 서버가 주는 상세 메시지가 있다면 출력
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
        '/api/users/accounts/$walletId',
        options: Options(headers: {'accesstoken': token}),
      );
    } catch (e) {
      rethrow;
    }
  }

  // 3. PIN 번호 생성/수정 (POST, PATCH /api/users/pin)
  Future<Response> createPin(PinCreateRequest request, String token) async {
    try {
      return await _dio.post(
        '/api/users/pin',
        data: request.toJson(), // 모델이 스스로 JSON 변환          },
        options: Options(headers: {'accesstoken': token}),
      );
    } catch (e) {
      rethrow;
    }
  }

  // 4. PIN 번호 변경 (USER_ACCOUNT_004)
  Future<Response> updatePin(PinUpdateRequest request, String token) async {
    try {
      return await _dio.patch(
        '/api/users/pin',
        data: request.toJson(), // 모델이 스스로 JSON 변환
        options: Options(headers: {'accesstoken': token}),
      );
    } catch (e) {
      rethrow;
    }
  }
}
