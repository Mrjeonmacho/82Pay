import 'package:dio/dio.dart';
import 'package:palipay_app/features/pin/models/pin_request_dto.dart'; // 혹은 http 패키지

class AccountService {
  // mock 서버 등록
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:3000',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ),
  );

  // 모든 요청에 공통으로 들어갈 헤더 설정을 위한 인터셉터 추천
  // 여기서는 명확성을 위해 각 메서드에 헤더를 직접 넣는 방식으로 작성

  // 1. 계좌 등록 (POST /api/users/accounts)
  Future<Response> linkAccount(Map<String, dynamic> data, String token) async {
    try {
      // 명세서 규격: walletId, bankCode, accountNumber, accountUsername, moneyCode
      return await _dio.post(
        '/api/users/accounts',
        data: data,
        options: Options(headers: {'accesstoken': token}),
      );
    } catch (e) {
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
