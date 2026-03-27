// lib/core/providers/user_provider.dart
// lib/core/providers/user_provider.dart

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserProvider extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();

  int? _userId;

  String? _userName;
  String? _userEmail;
  String? _countryCode = 'US';
  String? _accesstoken;
  String? _walletId;

  bool _isFirstCheck = true;

  // Getters
  int? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get countryCode => _countryCode;
  String? get accesstoken => _accesstoken;
  String? get walletId => _walletId;
  bool get isLoggedIn =>
      _accesstoken != null &&
      _accesstoken != 'null' &&
      _accesstoken!.isNotEmpty;
  bool get isFirstCheck => _isFirstCheck;

  /// 🚀 [1. 앱 시작 시] 저장된 정보를 복구하고 언어를 설정
  Future<void> checkLoginStatus(BuildContext context) async {
    _isFirstCheck = true;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'accesstoken');
      if (token != null && token.isNotEmpty && token != 'null') {
        _accesstoken = token;
        _walletId = await _storage.read(key: 'walletId');
        _userName = await _storage.read(key: 'userName');
        _userEmail = await _storage.read(key: 'userEmail'); // 👈 이 줄을 추가하세요!
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
    String? walletId,
    required BuildContext context,
  }) async {
    _accesstoken = token;
    _userId = userId ?? _userId;
    _userName = name ?? _userName;
    _userEmail = email ?? _userEmail;
    _countryCode = countryCode ?? _countryCode;
    _walletId = walletId ?? _walletId;

    // 💾 금고에 영구 저장
    await _storage.write(key: 'accesstoken', value: token);
    await _storage.write(key: 'countryCode', value: _countryCode ?? 'US');
    if (name != null) await _storage.write(key: 'userName', value: name);
    if (email != null)
      await _storage.write(key: 'userEmail', value: email); // 👈 이 줄을 추가하세요!
    if (walletId != null)
      await _storage.write(key: 'walletId', value: walletId);

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
    final Map<String, Locale> countryToLocale = {
      // 'KR': const Locale('ko'),
      'JP': const Locale('ja'),
      'CN': const Locale('zh'),
      'US': const Locale('en'),
    };
    final targetLocale = countryToLocale[countryCode] ?? const Locale('en');

    if (context.mounted && context.locale != targetLocale) {
      context.setLocale(targetLocale);
      debugPrint('🌐 언어 변경 완료: $targetLocale');
    }
  }

  /// 🧹 로그아웃
  Future<void> logout() async {
    _accesstoken = null;
    _userId = null;
    _userName = null;
    _walletId = null;
    await _storage.deleteAll();
    notifyListeners();
  }
}
