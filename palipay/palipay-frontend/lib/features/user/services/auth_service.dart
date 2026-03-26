import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:palipay_app/core/network/dio_client.dart';
import 'package:palipay_app/main_screen.dart';
import 'package:palipay_app/features/user/views/login_screen.dart';
import '../../../core/providers/user_provider.dart';

import '../../profile/providers/profile_provider.dart'; // 추가 (경로 확인!)
import '../../profile/models/profile_user_model.dart';

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

  // 로그
  Future<int> login(BuildContext context, String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {"email": email, "password": password},
      );

      final data = response.data;



      if (response.statusCode == 200) {
        final token = data['accessToken'];
        await _storage.write(key: 'accessToken', value: token);
        await _storage.write(key: 'grantType', value: data['grantType']);

        final userInfo = data['userInfo'];

        // 2. 💡 [핵심 추가] UserProvider에도 토큰을 꽂아줌
        if (context.mounted) {
          context.read<UserProvider>().setUserInfo(
          token: token,
          userId: userInfo['userId'],
          name: userInfo['name'],
          email: userInfo['email'],
          countryCode: userInfo['countryCode'],
          );

          // 2. 프로필 정보 업데이트 (ProfileProvider) 💡 추가!
          context.read<ProfileProvider>().setUser(
            ProfileUserModel.fromJson(userInfo)
          );
        }
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

  Future<void> checkAutoLoginStatus(BuildContext context) async {
    // 1. 사용자가 자동 로그인을 켰는지 확인
    bool autoLogin = await isAutoLoginEnabled();

    if (!context.mounted) return;

    if (!autoLogin) {
      // 자동 로그인 안 켰으면 로그인 페이지로
      goToLoginScreen(context);
      return;
    }

    // 2. Access Token이 있는지 확인
    String? at = await _storage.read(key: 'accessToken');

    if (!context.mounted) return;

    if (at != null) {
      // 토큰이 있다면 메인으로 (인터셉터가 알아서 검증하거나 첫 API 호출 시 판가름 남)
      context.read<UserProvider>().setUserInfo(token: at);
      goToMainScreen(context);
    } else {
      // 3. AT가 없거나 만료되었다면 Refresh 시도
      // 이때 DioClient의 쿠키(RT)가 서버로 날아가서 새 AT를 받아옵니다.
      bool success = await reissueToken();

      if (!context.mounted) return;

      if (success) {
        // 재발급 성공 시에도 새로운 토큰을 Provider에 넣어줘야 안전합니다.
        String? newAt = await _storage.read(key: 'accessToken');
        if (newAt != null) {
          context.read<UserProvider>().setUserInfo(token: newAt);
        }
        goToMainScreen(context);
      } else {
        goToLoginScreen(context);
      }
    }
  }

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

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (e) {
      print('로그아웃 서버 통신 에러: $e');
    } finally {
      await _storage.deleteAll();
      await DioClient().cookieJar.deleteAll();
    }
  }

  void goToLoginScreen(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void goToMainScreen(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }
}
