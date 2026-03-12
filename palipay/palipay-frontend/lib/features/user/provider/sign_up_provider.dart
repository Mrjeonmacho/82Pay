import 'package:flutter/material.dart';

class SignUpProvider extends ChangeNotifier {
  // 1. 컨트롤러들 (이제 여기서 관리합니다)
  final emailController = TextEditingController();
  final authCodeController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // 2. 상태 변수들
  int currentIndex = 0;
  bool isEmailValid = false;
  bool isCheckingEmail = false;
  bool isEmailAvailable = false;
  String selectedCountryCode = '+1';
  bool isPasswordMatch = false;

  // 3. 비즈니스 로직 (중복 체크)
  Future<void> checkEmailAvailability() async {
    final email = emailController.text;

    // 1. 여기서 이메일 형식이 맞는지 먼저 검사해서 상태를 업데이트해야 합니다!
    isEmailValid = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(email);

    // 2. 형식이 틀렸다면 중복 체크는 하지 않고 화면만 새로고침하고 종료
    if (!isEmailValid) {
      notifyListeners();
      return;
    }

    // 이메일 형식이 맞을 때만 중복 체크 로직 실행
    isCheckingEmail = true;
    isEmailAvailable = false;
    notifyListeners(); // UI에 알림

    await Future.delayed(const Duration(seconds: 1)); // 서버 통신 시뮬레이션

    isCheckingEmail = false;
    isEmailAvailable = (email != 'test@test.com');
    notifyListeners();
  }

  // 4. 상태 변경 함수들
  void setEmailValid(bool isValid) {
    isEmailValid = isValid;
    notifyListeners();
  }

  void setCountryCode(String code) {
    selectedCountryCode = code;
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }

  // 비밀번호가 보안 규칙을 통과했는지 확인하는 상태
  bool get isPasswordSecure {
    final pass = passwordController.text;
    if (pass.length < 8) return false;

    // 영어, 숫자, 특수문자 포함 여부 확인 (정규식)
    final hasLetter = pass.contains(RegExp(r'[a-zA-Z]'));
    final hasDigit = pass.contains(RegExp(r'[0-9]'));
    final hasSpecial = pass.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return hasLetter && hasDigit && hasSpecial;
  }

  // 비밀번호 일치 확인
  void checkPasswordLogic() {
    final pass = passwordController.text;
    final confirm = confirmPasswordController.text;

    // 비밀번호 일치 여부 업데이트
    isPasswordMatch = pass.isNotEmpty && confirm.isNotEmpty && pass == confirm;

    notifyListeners(); // 보안 규칙(get)은 호출될 때 계산되므로 알림만 주면 됨
  }

  @override
  void dispose() {
    // 컨트롤러 해제도 여기서 담당
    emailController.dispose();
    authCodeController.dispose();
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
