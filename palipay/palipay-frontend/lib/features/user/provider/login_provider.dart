// lib/features/user/provider/login_provider.dart
// lib/features/user/provider/login_provider.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/provider.dart';
import 'package:palipay_app/core/providers/user_provider.dart';
import 'package:palipay_app/features/account/providers/account_provider.dart';
import 'package:palipay_app/features/user/services/auth_service.dart';

class LoginProvider extends ChangeNotifier {
  final _authService = AuthService();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isAutoLogin = false;
  bool _showOverlayMessage = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isAutoLogin => _isAutoLogin;
  bool get showOverlayMessage => _showOverlayMessage;
  String? get errorMessage => _errorMessage;

  void setAutoLogin(bool value) {
    _isAutoLogin = value;
    notifyListeners();
  }

  void triggerPasswordChangedMessage() {
    _showOverlayMessage = true;
    notifyListeners();
    Future.delayed(const Duration(seconds: 3), () {
      _showOverlayMessage = false;
      notifyListeners();
    });
  }

  /// 로그아웃 후 로그인 화면 상태 초기화용
  void reset() {
    emailController.clear();
    passwordController.clear();
    _isLoading = false;
    _isAutoLogin = false;
    _showOverlayMessage = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// 🚀 로그인 실행
  Future<bool> login(BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic>? response = await _authService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      debugPrint("🔥 [LoginProvider] 서버 응답: $response");

      // 백엔드 키 기준 소문자 'accessToken'으로 통일
      if (response != null && response['accessToken'] != null) {
        final Map<String, dynamic>? userInfo =
            response['userInfo'] as Map<String, dynamic>?;

        if (context.mounted) {
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );
          final accountProvider = Provider.of<AccountProvider>(
            context,
            listen: false,
          );

          // 1. 유저 정보 저장 (walletId 제거 — AccountProvider가 관리)
          await userProvider.setUserInfo(
            token: response['accessToken'].toString(),
            name: userInfo?['name']?.toString() ?? 'User',
            countryCode: userInfo?['countryCode']?.toString() ?? 'US',
            email: userInfo?['email']?.toString(), // 이게 빠져있을 가능성 높음

            context: context,
          );

          // 2. 지갑 연동 상태 확인 (walletId 확정은 여기서)
          await accountProvider.refreshWalletInfo(context);
        }

        await _authService.setAutoLogin(_isAutoLogin);
        debugPrint("✅ 로그인 조건 통과! 메인으로 이동합니다.");
        return true;
      } else {
        _errorMessage = 'login.error_invalid';
        return false;
      }
    } catch (e) {
      debugPrint('🚨 Login Error: $e');
      _errorMessage = 'login.error_network';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> trySilentLogin() async {
    return await _authService.isAutoLoginEnabled();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
