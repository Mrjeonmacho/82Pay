import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8081';
  final _storage = const FlutterSecureStorage();

  // 이메일 중복 확인
  Future<bool> checkEmailDuplicate(String email) async {
    final url = Uri.parse(
      '$baseUrl/user/check',
    ).replace(queryParameters: {'type': 'email', 'value': email});

    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['isEmailAvailable'] ?? false;
      }

      return false;
    } catch (e) {
      print("이메일 중복 확인 에러: $e");
      return false;
    }
  }

  // 이메일 인증 코드 발송
  Future<bool> sendEmailCode(String email) async {
    final url = Uri.parse('$baseUrl/user/email/code');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
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
    final url = Uri.parse('$baseUrl/user/email/verification');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "authCode": code}),
      );
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result == true;
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
    final url = Uri.parse('$baseUrl/user/signup');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "name": name,
          "phoneNumber": phoneNumber,
          "countryCode": countryCode,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ [성공] 바디 내용: ${response.body}");
        return true;
      } else {
        // 400, 403, 500 에러 등이 날 때 백엔드가 보내주는 에러 이유를 확인!
        print("❌ [실패] 상태코드: ${response.statusCode}");
        print("❌ [실패] 에러내용: ${response.body}");
        return false;
      }
    } catch (e) {
      print("네트워크 에러: $e");
      return false;
    }
  }

  // 로그인
  Future<int> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/user/login');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // ⭐️ 토큰 저장 (캡처해주신 JSON 키값 기준)
        await _storage.write(key: 'accessToken', value: data['accessToken']);
        await _storage.write(key: 'refreshToken', value: data['refreshToken']);
        await _storage.write(key: 'grantType', value: data['grantType']);
        return 200;
      }
      return data.status;
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
    final url = Uri.parse('$baseUrl/user/reissue'); // 서버의 재발급 엔드포인트
    final refreshToken = await _storage.read(key: 'refreshToken');

    if (refreshToken == null) return false;

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refreshToken": refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
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
