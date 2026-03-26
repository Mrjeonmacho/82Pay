// providers/login_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:palipay_app/core/network/dio_client.dart';
import 'package:palipay_app/core/providers/user_provider.dart';
import 'package:palipay_app/features/wallet/providers/wallet_provider.dart';
import 'package:provider/provider.dart'; // 👈 추가 필요
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
      // 1. AuthService를 통해 로그인 시도 (토큰/유저정보 세팅됨)
      int statusCode = await _authService.login(context, email, password);

      if (statusCode == 200) {
        final String? token = context.read<UserProvider>().accessToken;

        if (token != null) {
          // Dio 헤더에 즉시 주입 (다음 API 호출을 위해)
          DioClient().dio.options.headers["Authorization"] = "Bearer $token";
        }

        // 2. 그 다음 지갑 정보 로드
        final walletProvider = context.read<WalletProvider>();
        await walletProvider.initWalletData();

        debugPrint('✅ [Login] 지갑 정보 로드 완료: ${walletProvider.walletId}');

        if (_isAutoLogin) {
          // 자동 로그인 관련 추가 로직이 필요하다면 여기에 작성
        }
        return true;
      } else {
        errorMessage = "Please check your email or password.";
        return false;
      }
    } catch (e) {
      debugPrint('🚨 Login Error: $e');
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
