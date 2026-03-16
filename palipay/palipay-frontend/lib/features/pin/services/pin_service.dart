import 'package:dio/dio.dart';
import 'package:palipay_app/core/constants/api_constants.dart';
import '../models/pin_request_dto.dart';
// core/network/dio_client.dart 가 있다면 이를 활용하는 것이 좋습니다.

class PinService {
  final Dio _dio = Dio(); // 실제로는 전역으로 관리되는 Dio 인스턴스를 쓰는 것이 좋습니다.

  // API 경로 설정 (팀 내 약속된 ApiConstants가 있다면 교체해 주세요)
  static const String _baseUrl = ApiConstants.pinSet;

  /// 1. 핀 번호 최초 생성 (USER_ACCOUNT_003)
  Future<bool> createPin(PinCreateRequest request) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/create',
        data: request.toJson(),
      );

      // 서버 응답이 200 또는 201이면 성공
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      // 에러 로그 출력 및 처리
      print('PIN Create Error: ${e.response?.data}');
      return false;
    }
  }

  /// 2. 핀 번호 변경 (USER_ACCOUNT_004)
  Future<bool> updatePin(PinUpdateRequest request) async {
    // 서버 연결 전 화면 테스트용
    await Future.delayed(const Duration(milliseconds: 300));

    if (request.oldPinNumber == '123456') {
      return true;
    }
    return false;

    // 서버 연결 후 아래 사용
    // try {
    //   final response = await _dio.put(
    //     '$_baseUrl/update',
    //     data: request.toJson(),
    //   );
    //   return response.statusCode == 200;
    // } on DioException catch (e) {
    //   print('PIN Update Error: ${e.response?.data}');
    //   return false;
    // }
  }

  /// 3. 핀 번호 검증 (송금/결제 전 확인용)
  Future<bool> verifyPin(int walletId, String pinNumber) async {
    // TODO: 화면 보기 위한 더미
    print("검증 요청 들어옴 -> ID: $walletId, PIN: '$pinNumber'");
    await Future.delayed(const Duration(milliseconds: 300));
    if (pinNumber == '123456') return true;

    return false;

    // try {
    //   final response = await _dio.post(
    //     '$_baseUrl/verify',
    //     data: {'walletId': walletId, 'pinNumber': pinNumber},
    //   );
    //   return response.statusCode == 200;
    // } on DioException catch (e) {
    //   print('PIN Verify Error: ${e.response?.data}');
    //   return false;
    // }
  }
}
