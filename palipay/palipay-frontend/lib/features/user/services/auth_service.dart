import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:palipay_app/core/network/dio_client.dart';

class AuthService {
  final Dio _dio = DioClient().dio;
  final _storage = const FlutterSecureStorage();

  // 이메일 중복 확인
  Future<bool> checkEmailDuplicate(String email) async {
    try {
      final response = await _dio.get(
        '/user/check',
        queryParameters: {'type': 'email', 'value': email},
      );

      if (response.statusCode == 200) {
        return response.data['isEmailAvailable'] ?? false;
      }

      return false;
    } catch (e) {
      print("이메일 중복 확인 에러: $e");
      return false;
    }
  }

  // 이메일 인증 코드 발송
  Future<bool> sendEmailCode(String email) async {
    try {
      final response = await _dio.post(
        '/user/email/code',
        data: {"email": email},
      );
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print("이메일 발송 에러: $e");
      return false;
    }
  }

  // 이메일 인증 코드 확인
  Future<bool> verifyEmailCode(String email, String code) async {
    try {
      final response = await _dio.post(
        '/user/email/verification',
        data: {"email": email, "authCode": code},
      );
      if (response.statusCode == 200) {
        return response.data == true;
      }
      return false;
    } catch (e) {
      print("이메일 인증 에러: $e");
      return false;
    }
  }

  // 회원가입 함수
  Future<bool> signUp(
    String email,
    String password,
    String name,
    String phoneNumber,
    String countryCode,
  ) async {
    try {
      final response = await _dio.post(
        '/user/signup',
        data: {
          "email": email,
          "password": password,
          "name": name,
          "phoneNumber": phoneNumber,
          "countryCode": countryCode,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ [성공] 바디 내용: ${response.data}");
        return true;
      } else {
        return false;
      }
    } on DioException catch (e) {
        print("❌ [실패] 상태코드: ${e.response?.statusCode}");
        print("❌ [실패] 에러내용: ${e.response?.data}");
        return false;
    } catch (e) {
      print("네트워크 에러: $e");
      return false;
    }
  }

  // 로그인
  Future<int> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/user/login',
        data: {"email": email, "password": password},
      );

      final data = response.data;

      if (response.statusCode == 200) {
        // ⭐️ 토큰 저장 (캡처해주신 JSON 키값 기준)
        await _storage.write(key: 'accessToken', value: data['accessToken']);
        await _storage.write(key: 'refreshToken', value: data['refreshToken']);
        await _storage.write(key: 'grantType', value: data['grantType']);
        return 200;
      }
      return data['status'] ?? 500;
    } on DioException catch (e) {
      return e.response?.data['status'] ?? 500;
    } catch (e) {
      return 500;
    }
  }

  // 자동로그인
  Future<void> setAutoLogin(bool useAutoLogin) async {
    if (useAutoLogin) {
      await _storage.write(key: 'useAutoLogin', value: 'true');
    } else {
      // 체크 해제 시 관련 데이터 삭제
      await _storage.delete(key: 'useAutoLogin');
    }
  }

  // 2. 자동 로그인 사용 여부 확인 (Splash 화면 등에서 사용)
  Future<bool> isAutoLoginEnabled() async {
    String? value = await _storage.read(key: 'useAutoLogin');
    return value == 'true';
  }

  Future<bool> reissueToken() async {
    final refreshToken = await _storage.read(key: 'refreshToken');

    if (refreshToken == null) return false;

    try {
      final response = await _dio.post(
        '/user/reissue',
        data: {"refreshToken": refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // ⭐️ 새로운 토큰들로 덮어쓰기
        await _storage.write(key: 'accessToken', value: data['accessToken']);
        await _storage.write(key: 'refreshToken', value: data['refreshToken']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // 저장된 토큰 가져오기 (API 호출 시 필요)
  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'accessToken');
  }

  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getAccessToken(); // 👈 여기서 재사용!
    final grantType = await _storage.read(key: 'grantType') ?? 'Bearer';

    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "$grantType $token",
    };
  }

  // 로그아웃 시 토큰 삭제
  Future<void> logout() async {
    await _storage.deleteAll();
  }
}
