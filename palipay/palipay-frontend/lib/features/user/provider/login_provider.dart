// providers/login_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginProvider extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _authService = AuthService();

  bool isLoading = false;
  String? errorMessage;
  bool _isAutoLogin = false;
  bool get isAutoLogin => _isAutoLogin;

  // 비밀번호 변경 완료 메시지 상태
  bool showOverlayMessage = false;

  void setAutoLogin(bool value) {
    _isAutoLogin = value;
    notifyListeners();
  }

  // 1. 비밀번호 변경 성공 메시지 로직 (Screen에서 이동)
  void triggerPasswordChangedMessage() async {
    showOverlayMessage = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    showOverlayMessage = false;
    notifyListeners();
  }

  // 자동 로그인 인지 판단 로직
  Future<bool> trySilentLogin() async {
    bool isEnabled = await _authService.isAutoLoginEnabled();
    if (isEnabled) {
      return await _authService.reissueToken();
    }
    return false;
  }

  // 2. 로그인 로직
  Future<bool> login(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      errorMessage = "Please enter both email and password.";
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // ⭐️ 이제 성공 여부가 아니라 코드를 받습니다.
      int statusCode = await _authService.login(context, email, password);

      if (statusCode == 200) {
        if (_isAutoLogin) {
          // secure_storage 등에 저장하는 로직 (예시)
          // await _storage.write(key: 'auto_login', value: 'true');
        }
        return true;
      } else {
        errorMessage = "Please check your email or password.";
        return false;
      }
    } catch (e) {
      errorMessage = "Connection error. Please check your network.";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
