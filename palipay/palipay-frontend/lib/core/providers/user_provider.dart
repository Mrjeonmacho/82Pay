// lib/core/providers/user_provider.dart

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserProvider extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();

  int? _userId;
  String? _userName;
  String? _userEmail;
  String? _countryCode = 'US';
  String? _accessToken;

  bool _isFirstCheck = true;

  // Getters
  int? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get countryCode => _countryCode;
  String? get accessToken => _accessToken;
  bool get isLoggedIn => _accessToken != null && _accessToken!.isNotEmpty;
  bool get isFirstCheck => _isFirstCheck;

  /// 🚀 [1. 앱 시작 시] 저장된 정보를 복구하고 언어를 설정
  Future<void> checkLoginStatus(BuildContext context) async {
    _isFirstCheck = true;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'accessToken');
      if (token != null && token.isNotEmpty) {
        _accessToken = token;
        _userName = await _storage.read(key: 'userName');
        _userEmail = await _storage.read(key: 'userEmail');
        _countryCode = await _storage.read(key: 'countryCode') ?? 'US';

        debugPrint('✅ [UserProvider] 복구 성공: $_userName ($_countryCode)');
        if (context.mounted) _applyLocaleByCountry(_countryCode!, context);
      }
    } catch (e) {
      debugPrint('🚨 [UserProvider] 체크 중 에러: $e');
    } finally {
      _isFirstCheck = false;
      notifyListeners();
    }
  }

  /// 🚀 [2. 로그인 시] 토큰을 포함한 전체 정보를 저장하고 언어 변경
  Future<void> setUserInfo({
    required String token,
    int? userId,
    String? name,
    String? email,
    String? countryCode,
    required BuildContext context,
  }) async {
    _accessToken = token;
    _userId = userId ?? _userId;
    _userName = name ?? _userName;
    _userEmail = email ?? _userEmail;
    _countryCode = countryCode ?? _countryCode;

    // 💾 SecureStorage 저장 (백엔드 기준 소문자 키로 통일)
    await _storage.write(key: 'accessToken', value: token);
    await _storage.write(key: 'countryCode', value: _countryCode ?? 'US');
    if (name != null) await _storage.write(key: 'userName', value: name);
    if (email != null) await _storage.write(key: 'userEmail', value: email);

    // 🌐 언어 적용
    if (context.mounted) _applyLocaleByCountry(_countryCode!, context);
    notifyListeners();
  }

  /// 🚀 [3. 회원가입 시] 토큰 없이 국적/이름 설정을 위해 SignUpProvider가 호출
  void setUserConfig({
    required String countryCode,
    String? name,
    String? email,
    required BuildContext context,
  }) {
    _countryCode = countryCode;
    _userName = name ?? _userName;
    _userEmail = email ?? _userEmail;

    // 🌐 회원가입 즉시 해당 국적 언어로 변경
    if (context.mounted) _applyLocaleByCountry(countryCode, context);
    notifyListeners();
  }

  /// 🌐 공통 언어 적용 로직
  void _applyLocaleByCountry(String countryCode, BuildContext context) {
    const countryToLocale = {
      'JP': Locale('ja'),
      'CN': Locale('zh'),
      'US': Locale('en'),
    };
    final targetLocale = countryToLocale[countryCode] ?? const Locale('en');

    if (context.mounted && context.locale != targetLocale) {
      context.setLocale(targetLocale);
      debugPrint('🌐 언어 변경 완료: $targetLocale');
    }
  }

  /// 🧹 로그아웃
  Future<void> logout(BuildContext context) async {
    // SecureStorage 전체 삭제 (토큰 포함 모든 캐시 제거)
    await _storage.deleteAll();

    _accessToken = null;
    _userId = null;
    _userName = null;
    _userEmail = null;
    _countryCode = 'US';
    _isFirstCheck = false;

    notifyListeners();
  }
}
