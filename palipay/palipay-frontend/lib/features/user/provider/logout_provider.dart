import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:palipay_app/core/providers/user_provider.dart';
import 'package:palipay_app/features/user/provider/login_provider.dart';
import '../services/auth_service.dart';

class LogoutProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> logout(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. 서버 로그아웃 + storage 삭제 + cookie 삭제
      await _service.logout();

      // 2. 앱 메모리에 남아있는 사용자 정보 초기화
      if (context.mounted) {
        await context.read<UserProvider>().logout(context);
        // 로그인 입력값 / 에러메시지 / 자동로그인 체크 초기화
        context.read<LoginProvider>().reset();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}