// 로그인 상태, 국가 코드, 기본 언어 등 전역 설정 관리할 수 있는 provider 파일

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants/bank_constants.dart';

/// PaliPay의 핵심 사용자 상태 및 글로벌 설정을 관리하는 프로바이더입니다.
class UserProvider extends ChangeNotifier {
  // 1. 사용자 핵심 상태 변수
  String _countryCode = 'US'; // 기본값은 미국으로 설정
  String? _userName;
  String? _userEmail;
  bool _isLoggedIn = false;

  // Getters
  String get countryCode => _countryCode;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  bool get isLoggedIn => _isLoggedIn;

  /// 현재 설정된 국가의 은행 리스트를 반환합니다.
  List<Map<String, dynamic>> get currentCountryBanks => 
      BankConstants.getBanks(_countryCode);

  /// 현재 설정된 국가의 기본 통화 코드를 반환합니다. (예: KRW, USD)
  String get currentCurrency => 
      BankConstants.getDefaultCurrency(_countryCode);

  /// 회원가입이나 로그인 성공 시 사용자의 글로벌 설정을 업데이트합니다.
  /// [countryCode]: 'KR', 'JP', 'US', 'CN' 등의 국가 코드
  void setUserConfig({
    required String countryCode,
    String? name,
    String? email,
    required BuildContext context,
  }) {
    _countryCode = countryCode;
    _userName = name;
    _userEmail = email;
    _isLoggedIn = true;

    // 2. 국가 코드에 따른 앱 언어 자동 변경 로직
    _applyLocaleByCountry(countryCode, context);

    notifyListeners();
  }

  /// 내부적으로 국가 코드에 맞는 Locale을 찾아 easy_localization에 적용합니다.
  void _applyLocaleByCountry(String countryCode, BuildContext context) {
    final Map<String, Locale> countryToLocale = {
      'KR': const Locale('ko'),
      'JP': const Locale('ja'),
      'CN': const Locale('zh'),
      'US': const Locale('en'),
    };

    final targetLocale = countryToLocale[countryCode] ?? const Locale('en');
    
    // 현재 앱의 언어와 다를 때만 변경 수행
    if (context.locale != targetLocale) {
      context.setLocale(targetLocale);
    }
  }

  /// 로그아웃 시 상태를 초기화합니다.
  void logout() {
    _countryCode = 'US';
    _userName = null;
    _userEmail = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}