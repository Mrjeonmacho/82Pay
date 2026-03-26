import 'package:dio/dio.dart';
import 'package:palipay_app/core/constants/api_constants.dart';
import '../models/pin_request_dto.dart';
import 'package:palipay_app/core/network/dio_client.dart';

class PinService {
  final Dio _dio = DioClient().dio;

  /// 1. 핀 번호 최초 생성 (USER_ACCOUNT_003)
  Future<bool> createPin(PinCreateRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.walletPin,
        data: request.toJson(),
      );

      // 서버 응답이 200이면 성공
      return response.statusCode == 200;
    } on DioException catch (e) {
      // 에러 로그 출력 및 처리
      print('PIN Create Error: ${e.response?.data}');
      rethrow;
    }
  }

  /// 2. 핀 번호 변경 (USER_ACCOUNT_004)
  Future<bool> updatePin(PinUpdateRequest request) async {
    try {
      final response = await _dio.patch(
        ApiConstants.walletPin,
        data: request.toJson(),
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      print('PIN Update Error: ${e.response?.data}');
      rethrow;
    }
  }

  /// 3. 핀 번호 검증 (송금/결제 전 확인용)
  Future<bool> verifyPin(PinVerifyRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.pinValidate,
        data: request.toJson(),
      );
      final data = response.data;

      // 200일 때 data.isValid == true 기대
      if (response.statusCode == 200) {
        return data['data']?['isValid'] == true;
      }

      return false;
    } on DioException catch (e) {
      print('PIN Verify Error: ${e.response?.data}');

      // 422도 "비밀번호 틀림" 이므로 예외를 다시 던지지 않고 false 처리 가능
      if (e.response?.statusCode == 422) {
        return false;
      }

      rethrow;
    }
  }
}
