import 'package:flutter/material.dart';
import 'package:worldbank_app/core/widgets/pali_input_field.dart';
import '../services/user_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final PageController _pageController = PageController();
  final UserService _userService = UserService();

  // 1단계 컨트롤러
  final _emailController = TextEditingController();
  final _pwController = TextEditingController();
  bool _isEmailChecked = false; // 중복확인 완료 여부

  // 2단계 컨트롤러
  final _nameController = TextEditingController(); // 이름 추가
  final _countryController = TextEditingController();
  final _bankCodeController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountPwController = TextEditingController();

  bool _isLoading = false;

  // 이메일 중복 확인 로직
  Future<void> _checkEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    final isAvailable = await _userService.checkEmailDuplicate(email);
    if (isAvailable) {
      setState(() => _isEmailChecked = true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('사용 가능한 이메일입니다.')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이미 사용 중인 이메일입니다.')));
    }
  }

  // 최종 회원가입 제출
  Future<void> _submitSignup() async {
    setState(() => _isLoading = true);

    final success = await _userService.signUp(
      _emailController.text.trim(),
      _pwController.text.trim(),
      _countryController.text.trim(),
      _nameController.text.trim(),
      _bankCodeController.text.trim(),
      _bankNameController.text.trim(),
      _accountPwController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // 스와이프 금지 (버튼으로만 이동)
        children: [_buildStep1(), _buildStep2()],
      ),
    );
  }

  // --- 1단계: 계정 정보 ---
  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "계정 정보를\n입력해주세요",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: PaliInputField(
                  hintText: "이메일 주소",
                  controller: _emailController,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _checkEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isEmailChecked
                      ? Colors.grey
                      : const Color(0xFFE2D696),
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "중복확인",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PaliInputField(
            hintText: "비밀번호",
            controller: _pwController,
            isPassword: true,
          ),
          const Spacer(),
          _buildNextButton(() {
            if (_isEmailChecked && _pwController.text.isNotEmpty) {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          }, "다음"),
        ],
      ),
    );
  }

  // --- 2단계: 핀테크 정보 ---
  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "상세 정보를\n입력해주세요",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            PaliInputField(hintText: "이름", controller: _nameController),
            const SizedBox(height: 16),
            PaliInputField(hintText: "국가 선택", controller: _countryController),
            const SizedBox(height: 16),
            PaliInputField(hintText: "은행 선택", controller: _bankNameController),
            const SizedBox(height: 16),
            PaliInputField(hintText: "은행 코드", controller: _bankCodeController),
            const SizedBox(height: 16),
            PaliInputField(
              hintText: "계좌 비밀번호 (4자리)",
              controller: _accountPwController,
              isPassword: true,
            ),
            const SizedBox(height: 40),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildNextButton(_submitSignup, "가입 완료"),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton(VoidCallback onPressed, String label) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE2D696),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
