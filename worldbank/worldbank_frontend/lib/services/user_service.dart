import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:worldbank_app/providers/bank_provider.dart';
import '../providers/auth_provider.dart';

class UserService {
  final _storage = const FlutterSecureStorage();

  final String baseUrl = dotenv.env['BASE_URL'] ?? "http://localhost:8080/api";

  // 이메일 중복 확인
  Future<bool> checkEmailDuplicate(String email) async {
    try {
      print(baseUrl);
      // 쿼리 파라미터를 포함한 Uri 생성
      final url = Uri.parse(
        "$baseUrl/user/check",
      ).replace(queryParameters: {'type': 'email', 'value': email});
      print(url);
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
          "email": email.trim(),
          "password": password.trim(),
          "name": name.trim(),
          "countryCode": countryCode.trim(),
          "bankCode": bankCode.trim(),
          "bankName": bankName.trim(),
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
  Future<int> login(BuildContext context, String email, String password) async {
    try {
      final url = Uri.parse('$baseUrl/user/login');
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "email": email.trim(),
              "password": password.trim(),
            }),
          )
          .timeout(const Duration(seconds: 100));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final String? token = data['accessToken'];
        print("DEBUG 1: 서버 응답 성공, 토큰 존재 여부: ${token != null}");

        if (token != null) {
          // 1. AuthProvider에 토큰 전달 및 파싱
          print("DEBUG 2: AuthProvider.login 호출 직전");
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
          authProvider.login(token);

          // 2. 파싱된 데이터 검증 (방어 코드)
          // 느낌표(!) 대신 안전하게 null 체크를 하고 넘어갑니다.
          final int? userId = authProvider.userId;
          final String? country = authProvider.country;

          print("DEBUG 3: 파싱 결과 -> ID: $userId, Country: $country");

          if (userId == null || country == null) {
            print("ERROR: 토큰 파싱 실패 또는 유저 정보 누락");
            return 500; // 파싱 실패 시 에러 반환
          }

          // 3. BankProvider 초기화 (로딩 해제 및 데이터 조회)
          print("DEBUG 4: BankProvider.init 호출");
          final bankProvider = Provider.of<BankProvider>(
            context,
            listen: false,
          );

          // await를 붙여서 데이터 조회가 끝날 때까지 기다립니다.
          await bankProvider.init(userId, country);

          return 200;
        }
      }

      // 서버가 에러 메시지를 보낸 경우 해당 상태값 반환
      return data['status'] ?? response.statusCode;
    } catch (e) {
      print("로그인 에러 발생: $e");
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
