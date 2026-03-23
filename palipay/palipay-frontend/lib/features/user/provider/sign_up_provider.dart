import 'dart:async';

import 'package:flutter/material.dart';
import 'package:palipay_app/features/user/services/auth_service.dart';

import 'package:palipay_app/features/user/provider/login_provider.dart';
import 'package:provider/provider.dart';
import 'package:palipay_app/core/providers/user_provider.dart';

class SignUpProvider extends ChangeNotifier {
  // 1. 컨트롤러들 (이제 여기서 관리합니다)
  final emailController = TextEditingController();
  final authCodeController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  // 2. 상태 변수들
  int currentIndex = 0;
  bool isEmailValid = false;
  bool isCheckingEmail = false;
  bool isEmailAvailable = false;
  String selectedCountryCode = '+1';
  bool isPasswordMatch = false;

  // --- 추가된 매핑 로직: 다이얼 코드를 국가 코드로 변환 ---
  String get _isoCountryCode {
    return {
      '+82': 'KR',
      '+1': 'US',
      '+81': 'JP',
      '+86': 'CN',
    }[selectedCountryCode] ?? 'US';
  }

  void resetData() {
    currentIndex = 0;
    emailController.clear();
    authCodeController.clear();
    nameController.clear();
    phoneController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    isEmailValid = false;
    isCheckingEmail = false;
    isEmailAvailable = false;
    selectedCountryCode = '+1';
    isPasswordMatch = false;
    stopAuthTimer();
    authSecondsRemaining = 180;
    isTimerRunning = false;
    notifyListeners();
  }

  // 타이머
  Timer? _authTimer;
  int authSecondsRemaining = 180; // 3분 (180초)
  bool isTimerRunning = false;

  // 1. 이메일 중복 체크
  Future<void> checkEmailAvailability() async {
    final email = emailController.text;

    // 여기서 이메일 형식이 맞는지 먼저 검사해서 상태를 업데이트해야 합니다!
    isEmailValid = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(email);

    // 형식이 틀렸다면 중복 체크는 하지 않고 화면만 새로고침하고 종료
    if (!isEmailValid) {
      isEmailAvailable = false;
      notifyListeners();
      return;
    }

    // 이메일 형식이 맞을 때만 중복 체크 로직 실행
    isCheckingEmail = true;
    notifyListeners(); // UI에 알림

    // 서버 통신(이메일 중복 확인)
    isEmailAvailable = await _authService.checkEmailDuplicate(email);

    isCheckingEmail = false;
    notifyListeners();
  }

  // 2. 이메일 인증 코드 발송
  Future<void> sendEmailCode() async {
    startAuthTimer();
    final email = emailController.text.trim();
    bool success = await _authService.sendEmailCode(email);
    debugPrint('이메일 발송 결과 : $success');
  }

  // 2-1. 재발송 로직
  Future<void> resendAuthCode() async {
    // 1. 기존 타이머가 있다면 즉시 취소하고 새로 시작 (UI 피드백)
    stopAuthTimer();
    startAuthTimer();

    // 2. 인증코드 컨트롤러 비우기 (새 코드를 받을 준비)
    authCodeController.clear();

    notifyListeners();

    // 3. 백그라운드에서 서버에 코드 발송 요청
    // 이메일 입력 단계에서 썼던 함수를 그대로 활용합니다.
    bool success = await _authService.sendEmailCode(
      emailController.text.trim(),
    );

    if (!success) {
      // 만약 서버 에러로 발송 실패 시, 타이머를 멈추거나 사용자에게 알림
      // stopAuthTimer();
      debugPrint("재발송 실패: 서버 응답 에러");
    }
  }

  // 3. 이메일 인증 코드 검증
  Future<bool> verifyEmailCode() async {
    final email = emailController.text.trim();
    final code = authCodeController.text.trim();

    // AuthService를 통해 서버에 확인 요청
    bool success = await _authService.verifyEmailCode(email, code);

    if (success) {
      stopAuthTimer(); // 인증 성공 시 타이머 멈춤
    }
    return success;
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

  // 5. 최종 회원가입 요청
  Future<bool> finalSignUp(BuildContext context) async {
    // 1. 혹시 들어갔을지 모르는 숫자가 아닌 모든 문자 제거
    String cleanPhone = phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');

    // 2. 한국(+82), 일본(+81) 등 0으로 시작하는 번호의 경우 맨 앞 0 제거 (글로벌 표준)
    if (cleanPhone.startsWith('0')) {
      cleanPhone = cleanPhone.substring(1);
    }

    // 3. 국가 코드와 합체 (+82 + 1012345678 = +821012345678)
    final String internationalPhone = '$selectedCountryCode$cleanPhone';

    debugPrint("Final DB Phone Number: $internationalPhone");

    // 4. 최종 데이터 전송
    bool success = await _authService.signUp(
      emailController.text.trim(),
      passwordController.text.trim(),
      nameController.text.trim(),
      internationalPhone,
      selectedCountryCode,
    );

    // [추가] user_provider 에 데이터 전달 로직
    if (success && context.mounted) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      // 회원가입 단계에서 정해진 국가/이름/이메일을 전역 프로바이더에 장착
      userProvider.setUserConfig(
        countryCode: _isoCountryCode, // 매핑된 KR, US 등 전달
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        context: context, // 여기서 언어 자동 변경(setLocale)이 실행됨
      );
    }
    return success;
  }

  // 인증 코드 발송 및 타이머 시작
  void startAuthTimer() {
    _authTimer?.cancel(); // 기존 타이머가 있다면 종료
    authSecondsRemaining = 180;
    isTimerRunning = true;
    notifyListeners();

    _authTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (authSecondsRemaining > 0) {
        authSecondsRemaining--;
        notifyListeners();
      } else {
        stopAuthTimer();
      }
    });
  }

  void stopAuthTimer() {
    _authTimer?.cancel();
    isTimerRunning = false;
    notifyListeners();
  }

  // 남은 시간을 00:00 형식으로 변환하는 getter
  String get timerText {
    int minutes = authSecondsRemaining ~/ 60;
    int seconds = authSecondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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
    _authTimer?.cancel(); // 메모리 누수 방지
    super.dispose();
  }
}
