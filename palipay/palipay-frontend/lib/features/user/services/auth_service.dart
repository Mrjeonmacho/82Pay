// lib/features/user/services/auth_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:palipay_app/core/network/dio_client.dart';

class AuthService {
  final Dio _dio = DioClient().dio;
  final _storage = const FlutterSecureStorage();

  // 1. 이메일 중복 확인
  Future<bool> checkEmailDuplicate(String email) async {
    try {
      final response = await _dio.get(
        '/user/check',
        queryParameters: {'type': 'email', 'value': email},
      );
      return response.data['isEmailAvailable'] ?? false;
    } catch (e) {
      debugPrint("이메일 중복 확인 에러: $e");
      return false;
    }
  }

  // 2. 이메일 인증 코드 발송
  Future<bool> sendEmailCode(String email) async {
    try {
      final response = await _dio.post(
        '/user/email/code',
        data: {"email": email},
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("이메일 발송 에러: $e");
      return false;
    }
  }

  // 3. 이메일 인증 코드 확인
  Future<bool> verifyEmailCode(String email, String code) async {
    try {
      final response = await _dio.post(
        '/user/email/verification',
        data: {"email": email, "authCode": code},
      );
      return response.data == true;
    } catch (e) {
      debugPrint("이메일 인증 에러: $e");
      return false;
    }
  }

  // 4. 회원가입
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
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      // 💡 [중요] 이 코드를 넣어서 로그를 다시 보세요!
      // 서버가 "어떤 필드 때문에 화가 났는지" 상세히 알려줍니다.
      debugPrint("❌ [서버 응답 상세]: ${e.response?.data}");

      debugPrint("회원가입 에러: $e");
      return false;
    }
  }

  // 🚀 5. 로그인 (Provider에서 가공할 수 있게 Map 반환)
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {"email": email, "password": password},
      );

      if (response.statusCode == 200 && response.data != null) {
        debugPrint("🔥 서버 응답 바디: ${response.data}");
        final data = response.data;

        // 🚀 [수정] 로그에 찍힌 대로 'accessToken' (T 대문자) 사용
        final String? token = data['accessToken'];

        if (token != null) {
          // 내부 저장 키는 소문자로 통일해도 되지만, 꺼낼 때와 맞추세요.
          await _storage.write(key: 'accessToken', value: token);
          return data as Map<String, dynamic>;
        } else {
          debugPrint("🚨 로그인 실패: 토큰이 응답에 없습니다.");
          return null;
        }
      }
      return null;
    } on DioException catch (e) {
      // 💡 아래 줄을 추가해서 로그를 다시 보세요!
      // 서버가 "비밀번호가 틀렸다" 혹은 "이메일 형식이 아니다"라고 말해줄 겁니다.
      debugPrint("❌ 서버가 보낸 에러 상세: ${e.response?.data}");
      debugPrint("❌ 로그인 API 에러: ${e.response?.statusCode}");
      return null;
    } catch (e) {
      debugPrint("🚨 로그인 중 예기치 못한 에러: $e");
      return null;
    }
  }

  // 🚀 6. [추가됨] 자동 로그인 설정 저장
  Future<void> setAutoLogin(bool useAutoLogin) async {
    if (useAutoLogin) {
      await _storage.write(key: 'useAutoLogin', value: 'true');
    } else {
      await _storage.delete(key: 'useAutoLogin');
    }
  }

  // 🚀 7. [추가됨] 자동 로그인 사용 여부 확인
  Future<bool> isAutoLoginEnabled() async {
    String? value = await _storage.read(key: 'useAutoLogin');
    return value == 'true';
  }

  // 8. 토큰 재발급
  Future<bool> reissueToken() async {
    try {
      final response = await _dio.post('/auth/reissue');
      if (response.statusCode == 200) {
        final data = response.data;
        await _storage.write(key: 'accessToken', value: data['accessToken']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // 9. 로그아웃
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (e) {
      debugPrint('로그아웃 서버 에러: $e');
    } finally {
      // 언어 설정용 countryCode는 남기고,
      // 로그인/사용자 정보만 삭제
      await _storage.delete(key: 'accessToken');
      await _storage.delete(key: 'walletId');
      await _storage.delete(key: 'userName');
      await _storage.delete(key: 'userEmail');
      await _storage.delete(key: 'useAutoLogin');
      await DioClient().cookieJar.deleteAll();
    }
  }
}
