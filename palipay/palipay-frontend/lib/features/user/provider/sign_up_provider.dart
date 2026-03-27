import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:palipay_app/core/providers/user_provider.dart';
import 'package:palipay_app/features/user/services/auth_service.dart';

class SignUpProvider extends ChangeNotifier {
  final _authService = AuthService();

  // 1. 입력 컨트롤러
  final emailController = TextEditingController();
  final authCodeController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // 2. 상태 변수
  int currentIndex = 0;
  bool isEmailValid = false;
  bool isCheckingEmail = false;
  bool isEmailAvailable = false;
  String selectedCountryCode = 'US'; // 기본 국가번호
  bool isPasswordMatch = false;
  bool _isLoading = false;

  // 3. 타이머 관련
  Timer? _authTimer;
  int authSecondsRemaining = 180; // 3분
  bool isTimerRunning = false;

  // Getters
  bool get isLoading => _isLoading;

  // --- 비즈니스 로직 ---

  /// 🚀 [Step 1] 이메일 중복 확인
  Future<void> checkEmailAvailability() async {
    final email = emailController.text.trim();
    // 이메일 정규식 검사
    isEmailValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

    if (!isEmailValid) {
      isEmailAvailable = false;
      notifyListeners();
      return;
    }

    isCheckingEmail = true;
    notifyListeners();

    isEmailAvailable = await _authService.checkEmailDuplicate(email);

    isCheckingEmail = false;
    notifyListeners();
  }

  /// 🚀 [Step 2] 인증 코드 발송
  Future<void> sendEmailCode() async {
    startAuthTimer();
    final email = emailController.text.trim();
    await _authService.sendEmailCode(email);
  }

  /// 🚀 [Step 2] 인증 코드 검증
  Future<bool> verifyEmailCode() async {
    final email = emailController.text.trim();
    final code = authCodeController.text.trim();

    bool success = await _authService.verifyEmailCode(email, code);
    if (success) {
      stopAuthTimer();
    }
    return success;
  }

  /// 🚀 실시간 보안 검증 게터
  /// 영어, 숫자, 특수문자 조합 8자 이상인지 확인
  bool get isPasswordSecure {
    final pass = passwordController.text;
    if (pass.length < 8) return false;

    final hasLetter = pass.contains(RegExp(r'[a-zA-Z]'));
    final hasDigit = pass.contains(RegExp(r'[0-9]'));
    final hasSpecial = pass.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return hasLetter && hasDigit && hasSpecial;
  }

  /// 🚀 비밀번호 로직 체크 (onChanged에서 호출됨)
  void checkPasswordLogic() {
    final pass = passwordController.text;
    final confirm = confirmPasswordController.text;

    // 비밀번호 일치 여부 업데이트
    isPasswordMatch = pass.isNotEmpty && confirm.isNotEmpty && pass == confirm;

    // UI 갱신 (에러 메시지 실시간 반영을 위함)
    notifyListeners();
  }

  /// 🚀 [Final Step] 최종 회원가입 요청
  Future<bool> finalSignUp(BuildContext context) async {
    _setLoading(true);

    // 1. 전화번호 가공 (특수문자나 공백만 제거하고 번호는 그대로 유지)
    final String cleanPhone = phoneController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    try {
      // 2. 서버 데이터 전송 (국가번호 조합 없이 순수 번호와 KR만 전송)
      bool success = await _authService.signUp(
        emailController.text.trim(),
        passwordController.text.trim(),
        nameController.text.trim(),
        cleanPhone, // 예: 01012345678
        selectedCountryCode, // 예: KR
      );

      // 3. 성공 시 전역 설정 업데이트 (언어 포함)
      if (success && context.mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);

        userProvider.setUserConfig(
          countryCode: selectedCountryCode, // 🌐 KR, JP 등 전달
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          context: context,
        );
      }
      return success;
    } catch (e) {
      debugPrint("🚨 가입 에러: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // --- 상태 관리 메서드 ---

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }

  void setCountryCode(String code) {
    selectedCountryCode = code;
    notifyListeners();
  }

  // --- 타이머 관리 ---

  /// 🚀 인증 코드 재발송
  Future<void> resendAuthCode() async {
    stopAuthTimer(); // 기존 타이머 중지
    startAuthTimer(); // 새 타이머 시작
    authCodeController.clear(); // 입력창 초기화

    final email = emailController.text.trim();
    await _authService.sendEmailCode(email);

    notifyListeners();
    debugPrint("🔄 [SignUp] 인증 코드 재발송 완료");
  }

  /// 🚀 타이머 시작
  void startAuthTimer() {
    _authTimer?.cancel();
    authSecondsRemaining = 180;
    isTimerRunning = true;
    notifyListeners();

    _authTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (authSecondsRemaining > 0) {
        authSecondsRemaining--;
        notifyListeners(); // 매 초마다 UI 갱신 (타이머 텍스트 업데이트)
      } else {
        stopAuthTimer();
      }
    });
  }

  /// 🚀 타이머 중지
  void stopAuthTimer() {
    _authTimer?.cancel();
    isTimerRunning = false;
    notifyListeners();
  }

  /// 🚀 타이머 00:00 형식 변환
  String get timerText {
    int minutes = authSecondsRemaining ~/ 60;
    int seconds = authSecondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // --- 초기화 및 해제 ---

  void resetData() {
    currentIndex = 0;
    emailController.clear();
    authCodeController.clear();
    nameController.clear();
    phoneController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    isEmailValid = false;
    isEmailAvailable = false;
    _isLoading = false;
    stopAuthTimer();
    notifyListeners();
  }

  void resetEmailFlow() {
    authCodeController.clear();
    isEmailAvailable = false;
    stopAuthTimer();
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    authCodeController.dispose();
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _authTimer?.cancel();
    super.dispose();
  }
}
