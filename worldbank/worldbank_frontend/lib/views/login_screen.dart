import 'package:flutter/material.dart';
import 'package:worldbank_app/core/widgets/pali_input_field.dart';
import '../services/user_service.dart'; // 방금 만든 서비스 임포트

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ID와 비밀번호를 입력해주세요.')));
      setState(() => _isLoading = false);
      return;
    }

    final result = await _userService.login(email, password);

    setState(() => _isLoading = false);

    if (result == 200) {
      // 로그인 성공 시 메인 화면으로 이동 (예시: /home)
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('로그인 실패 (코드: $result)')));
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
              PaliInputField(hintText: 'ID', controller: _idController),
              const SizedBox(height: 16),

              // 3. PW 입력 (공통 위젯 사용)
              PaliInputField(
                hintText: 'PW',
                controller: _pwController,
                isPassword: true,
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
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
