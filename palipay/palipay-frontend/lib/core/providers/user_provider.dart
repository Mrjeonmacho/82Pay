// 로그인 상태, 국가 코드, 기본 언어 등 전역 설정 관리할 수 있는 provider 파일

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

// lib/core/providers/user_provider.dart

class UserProvider extends ChangeNotifier {
  int? _userId; // 💡 추가
  String? _userName;
  String? _userEmail;
  String? _countryCode = 'US'; // 기본값; // 💡 추가
  String? _accessToken;
  String? _walletId; // 💾 walletId 추가

  // Getters
  int? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get countryCode => _countryCode;
  String? get accessToken => _accessToken;
  String? get walletId => _walletId; // 💾 walletId getter
  bool get isLoggedIn => _accessToken != null;

  void setToken(String token) {
    _accessToken = token;
    // notifyListeners(); // 초기화 시점에는 필요에 따라 선택
  }

  // 💡 추가: 앱 시작 시 필요한 정보를 다시 세팅하는 메서드
  void restoreUser({
    required String token,
    String? walletId,
    String? userName,
  }) {
    _accessToken = token;
    _walletId = walletId;
    _userName = userName;
    notifyListeners();
  }

  // 💡 에러 해결 1: AuthService가 찾는 바로 그 메서드
  void setUserInfo({
    required String token,
    int? userId,
    String? name,
    String? email,
    String? countryCode,
    String? walletId, // 💾 walletId 파라미터 추가
  }) {
    _accessToken = token;
    _userId = userId ?? _userId;
    _userName = name ?? _userName;
    _userEmail = email ?? _userEmail;
    _countryCode = countryCode ?? _countryCode;
    _walletId = walletId ?? _walletId; // 💾 walletId 저장

    notifyListeners();
  }

  // 💡 에러 해결 2: SignUpProvider 등이 찾는 설정 메서드
  void setUserConfig({
    required String countryCode,
    String? name,
    String? email,
    required BuildContext context,
  }) {
    _countryCode = countryCode;
    _userName = name ?? _userName;
    _userEmail = email ?? _userEmail;

    // 내부 메서드 호출
    _applyLocaleByCountry(countryCode, context);
    notifyListeners();
  }

  // 💡 에러 해결 3: 내부에서 언어 설정을 처리하는 메서드
  void _applyLocaleByCountry(String countryCode, BuildContext context) {
    final Map<String, Locale> countryToLocale = {
      'KR': const Locale('ko'),
      'JP': const Locale('ja'),
      'CN': const Locale('zh'),
      'US': const Locale('en'),
    };

    final targetLocale = countryToLocale[countryCode] ?? const Locale('en');

    if (context.locale != targetLocale) {
      context.setLocale(targetLocale);
    }
  }

  void logout() {
    _userId = null;
    _userName = null;
    _userEmail = null;
    _countryCode = null;
    _accessToken = null;
    _walletId = null; // 💾 walletId도 초기화
    notifyListeners();
  }
}
