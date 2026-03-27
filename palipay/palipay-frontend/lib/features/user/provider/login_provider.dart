// lib/features/user/provider/login_provider.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:palipay_app/core/providers/user_provider.dart';
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

      // 🔍 디버깅: 서버 응답 구조 확인용
      debugPrint("🔥 [LoginProvider] 서버 응답: $response");

      // 1. [체크] 서버 로그에 찍힌 키값 'accessToken' (T 대문자) 사용
      if (response != null && response['accessToken'] != null) {
        // 2. [핵심] 유저 정보는 'userInfo' 내부에 있음
        final Map<String, dynamic>? userInfo =
            response['userInfo'] as Map<String, dynamic>?;

        if (context.mounted) {
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );

          // 3. 데이터 매칭 (userInfo에서 이름과 국가코드를 꺼냄)
          await userProvider.setUserInfo(
            token: response['accessToken'].toString(),
            name: userInfo?['name']?.toString() ?? "User",
            countryCode: userInfo?['countryCode']?.toString() ?? 'JP',
            // 만약 서버에서 walletId를 userInfo 밖에서 주면 response['walletId']로 수정
            walletId: userInfo?['userId']?.toString(),
            context: context,
          );
        }

        await _authService.setAutoLogin(_isAutoLogin);
        debugPrint("✅ 로그인 조건 통과! 메인으로 이동합니다.");
        return true;
      } else {
        // 토큰을 찾지 못한 경우
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
