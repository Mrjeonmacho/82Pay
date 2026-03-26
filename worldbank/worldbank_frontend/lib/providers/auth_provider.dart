import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthProvider extends ChangeNotifier {
  String? _accessToken;
  String? _country;
  int? _userId;

  // 외부에서 접근할 Getter
  String? get accessToken => _accessToken;
  String? get country => _country;
  int? get userId => _userId;
  bool get isAuthenticated => _accessToken != null;

  // 로그인 성공 시 호출할 함수
  void login(String token) {
    _accessToken = token;
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

      // 'sub' 값을 가져와서 타입에 상관없이 int로 변환
      var subValue = decodedToken['sub'];
      if (subValue != null) {
        _userId = int.tryParse(subValue.toString());
      }

      _country = decodedToken['country'] ?? 'US';
      notifyListeners();
      print("DEBUG: AuthProvider 저장 완료 - ID: $_userId, Country: $_country");
    } catch (e) {
      print("JWT 파싱 에러: $e");
    }
  }

  // 로그아웃
  void logout() {
    _accessToken = null;
    _country = null;
    _userId = null;
    notifyListeners();
  }
}
