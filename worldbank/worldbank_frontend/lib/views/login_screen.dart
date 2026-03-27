import 'package:flutter/material.dart';
import 'package:worldbank_app/core/widgets/pali_input_field.dart';
import '../services/user_service.dart'; // 방금 만든 서비스 임포트
import 'main_screen.dart';
import 'signup_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final UserService _userService = UserService();
  bool _isLoading = false;

  // 로그인 함수 호출
  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    final email = _idController.text.trim();
    final password = _pwController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('login.messages.error_empty_fields'.tr())),
      );
      setState(() => _isLoading = false);
      return;
    }

    final result = await _userService.login(context, email, password);

    setState(() => _isLoading = false);

    if (result == 200) {
      // 로그인 성공 시 메인 화면으로 이동 (예시: /home)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ), // MainScreen 또는 HomeScreen 클래스명
        (route) => false, // 로그인 전의 모든 페이지 스택(로그인창 등)을 제거해서 뒤로가기 방지
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'login.messages.error_login_failed'.tr(args: [result.toString()]),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // 1. World Bank 로고
              Image.asset(
                'assets/images/worldlogo.png',
                height: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 50),

              // 2. ID 입력 (공통 위젯 사용)
              PaliInputField(
                hintText: 'login.labels.id'.tr(),
                controller: _idController,
                maxLength: 100,
                isCounterText: true,
              ),
              const SizedBox(height: 16),

              // 3. PW 입력 (공통 위젯 사용)
              PaliInputField(
                hintText: 'login.labels.pw'.tr(),
                controller: _pwController,
                isPassword: true,
                maxLength: 100,
                isCounterText: true,
              ),
              const SizedBox(height: 40),

              // 4. 로그인 버튼 (기존 디자인 테마 적용)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE2D696), // 골드톤 유지
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // 인풋 필드 곡률과 통일
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(
                          'login.buttons.login'.tr(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "login.labels.no_account".tr(),
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  TextButton(
                    onPressed: () {
                      // 회원가입 화면으로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFE2D696), // 골드 포인트 컬러
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(
                      "login.buttons.signup".tr(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration:
                            TextDecoration.underline, // 밑줄 추가로 클릭 가능해보이게
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
