import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserService {
  final _storage = const FlutterSecureStorage();

  String get baseUrl =>
      dotenv.get("BASE_URL", fallback: "http://localhost:8080");

  // 이메일 중복 확인
  Future<bool> checkEmailDuplicate(String email) async {
    try {
      // 쿼리 파라미터를 포함한 Uri 생성
      final url = Uri.parse(baseUrl).replace(
        path: '/user/check',
        queryParameters: {'type': 'email', 'value': email},
      );

      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print("이메일 중복 확인 에러: $e");
      return false;
    }
  }

  // 회원가입 함수
  Future<bool> signUp(
    String email,
    String password,
    String countryCode,
    String name,
    String bankCode,
    String bankName,
    String accountPassword,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/user/signup');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "name": name,
          "countryCode": countryCode,
          "bankCode": bankCode,
          "bankName": bankName,
          "accountPassword": accountPassword,
        }),
      );

      if (response.statusCode == 200) {
        print("✅ [성공] 바디 내용: ${response.body}");
        return true;
      } else {
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
    try {
      final url = Uri.parse('$baseUrl/user/login');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _storage.write(key: 'userId', value: data['userId']?.toString());
        await _storage.write(key: 'accessToken', value: data['accessToken']);
        return 200;
      }

      // 서버에서 내려주는 에러 status가 있다면 반환, 없으면 응답 코드 반환
      return data['status'] ?? response.statusCode;
    } catch (e) {
      print("로그인 에러: $e");
      return 500;
    }
  }

  // 로그아웃
  Future<void> logout() async {
    try {
      final url = Uri.parse('$baseUrl/user/logout');
      final headers = await getAuthHeaders();

      await http.post(url, headers: headers);
    } catch (e) {
      print('로그아웃 서버 통신 에러: $e');
    } finally {
      await _storage.deleteAll();

      print('✅ 로그아웃 완료: 로컬 데이터 삭제됨');
    }
  }

  // 저장된 토큰 가져오기 (API 호출 시 필요)
  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'accessToken');
  }

  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getAccessToken();

    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }
}
