import 'dart:math' as Math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';
import 'sign_up_success_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  // 페이지 이동을 제어하기 위한 컨트롤러
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>(); // Form의 상태를 관리하는 키
  int _currentIndex = 0;

  // 각 단계에서 입력받을 데이터를 저장할 변수들
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _authCodeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  // --- 새로운 상태 변수 추가 ---
  bool _isEmailValid = false; // 이메일 형식 유효성
  bool _isCheckingEmail = false; // 서버 중복 확인 중 로딩 상태
  bool _isEmailAvailable = false; // 사용 가능한 이메일 여부

  @override
  void initState() {
    super.initState();
    // 0.5초 동안 4번 좌우로 흔들리는 설정
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0)
        .chain(CurveTween(curve: Curves.elasticIn)) // 흔들림 효과를 위한 커브
        .animate(_shakeController);
  }

  @override
  void dispose() {
    // 메모리 누수 방지를 위해 컨트롤러들을 해제합니다.
    _shakeController.dispose();
    _pageController.dispose();
    _emailController.dispose();
    _authCodeController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- 가상 이메일 중복 확인 로직 추가 (서버 연동 대비) ---
  Future<void> _checkEmailAvailability(String email) async {
    if (!_isEmailValid) return;

    setState(() {
      _isCheckingEmail = true;
      _isEmailAvailable = false;
    });

    // 서버 통신 시뮬레이션
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isCheckingEmail = false;
      // 'test@test.com'인 경우만 중복된 것으로 가정
      _isEmailAvailable = (email != 'test@test.com');
    });
  }

  // 다음 단계로 이동하는 함수
  void _onNextPressed() {
    // 이메일 단계에서 중복 확인이 안 된 경우 예외 처리
    if (_currentIndex == 0 && (!_isEmailAvailable || _isCheckingEmail)) {
      _shakeController.forward(from: 0.0);
      return;
    }

    if (_formKey.currentState!.validate()) {
      if (_currentIndex < 3) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SignUpSuccessScreen()),
        );
      }
    } else {
      _shakeController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentIndex > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
              )
            : null,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 상단 공통 로고 영역
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Image.asset(
                  'assets/images/logos/palilogo1.png',
                  height: 100,
                ), // 경로 확인 필요
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    Text(
                      'Create Your Account',
                      style: AppTextStyles.titleLarge,
                    ),
                    const SizedBox(height: 25), // 여백 확보
                    // --- 커스텀 스텝 진행 바 시작 ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStepItem(0, 'Email'),
                        _buildStepLine(0),
                        _buildStepItem(1, 'Confirm email'),
                        _buildStepLine(1),
                        _buildStepItem(2, 'Enter personal info'),
                        _buildStepLine(2),
                        _buildStepItem(3, 'Password'),
                      ],
                    ),
                    // --- 커스텀 스텝 진행 바 끝 ---
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 단계별 콘텐츠 영역 (PageView)
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(), // 스와이프 차단
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  children: [
                    _buildEmailStep(), // Step 0
                    _buildAuthStep(), // Step 1
                    _buildProfileStep(), // Step 2
                    _buildPasswordStep(), // Step 3
                  ],
                ),
              ),

              // 하단 공통 버튼 영역
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: PaliButton(
                  text: _currentIndex == 3 ? 'Sign Up' : 'Next',
                  onPressed: _onNextPressed,
                  backgroundColor: AppColors.mainBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 각 단계별 화면 구성 함수들 ---

  // 1. 각 단계별 아이콘과 텍스트를 그리는 함수
  Widget _buildStepItem(int index, String label) {
    bool isCurrent = _currentIndex == index;
    bool isDone = _currentIndex > index;

    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isCurrent || isDone
                ? AppColors.mainBlue
                : AppColors.disabledBackground,
            shape: BoxShape.circle,
            border: isCurrent
                ? Border.all(
                    color: AppColors.mainBlue.withOpacity(0.3),
                    width: 4,
                  )
                : null,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isCurrent || isDone
                          ? Colors.white
                          : AppColors.disabledBackground,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isCurrent
                ? AppColors.mainBlue
                : AppColors.disabledBackground,
          ),
        ),
      ],
    );
  }

  // 2. 단계 사이를 잇는 선을 그리는 함수
  Widget _buildStepLine(int index) {
    bool isDone = _currentIndex > index;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 20), // 텍스트 높이만큼 위로 보정
        height: 2,
        color: isDone ? AppColors.mainBlue : AppColors.disabledBackground,
      ),
    );
  }

  // 1. 이메일 입력 , 검증, 중복체크 추가
  Widget _buildEmailStep() {
    return _buildStepLayout(
      title: 'Email',
      child: PaliInputField(
        hintText: 'Enter your email',
        controller: _emailController,
        onChanged: (value) {
          final isValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
          ).hasMatch(value);
          setState(() => _isEmailValid = isValid);

          if (isValid) {
            _checkEmailAvailability(value);
          }
        },
        suffixIcon: _isCheckingEmail
            ? const SizedBox(
                width: 20,
                height: 20,
                child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : null, // 아이콘은 validator가 처리하는 에러 메시지와 중복될 수 있어 비워두거나 체크만 표시
        validator: (value) {
          if (value == null || value.isEmpty) return 'Enter your email';
          if (!_isEmailValid) return 'Invalid email address.';

          // --- 핵심: 서버 체크 결과 반영 ---
          if (!_isCheckingEmail &&
              !_isEmailAvailable &&
              value == 'test@test.com') {
            return 'This email is already taken.'; // 이 메시지가 반환되어야 빨간 테두리가 뜹니다!
          }
          return null;
        },
      ),
    );
  }

  // 2. 이메일 확인
  Widget _buildAuthStep() {
    return _buildStepLayout(
      title: 'Verification Code',
      child: PaliInputField(
        hintText: 'Enter 6-digit code',
        controller: _authCodeController,
      ),
    );
  }

  // 3. 프로필 설정
  Widget _buildProfileStep() {
    return Column(
      children: [
        _buildStepLayout(
          title: 'Name',
          child: PaliInputField(
            hintText: 'Full Name',
            controller: _nameController,
          ),
        ),
        const SizedBox(height: 16),
        _buildStepLayout(
          title: 'Phone Number',
          child: PaliInputField(
            hintText: 'Phone Number',
            controller: _phoneController,
          ),
        ),
      ],
    );
  }

  // 4. 비밀번호 설정
  Widget _buildPasswordStep() {
    return Column(
      children: [
        _buildStepLayout(
          title: 'Password',
          child: PaliInputField(
            hintText: 'Set Password',
            controller: _passwordController,
            isPassword: true,
          ),
        ),
        const SizedBox(height: 16),

        _buildStepLayout(
          title: 'Confirm Password',
          child: PaliInputField(
            hintText: 'Confirm Password',
            controller: _confirmPasswordController,
            isPassword: true,
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Passwords do not match.';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  // 단계별 공통 레이아웃 래퍼
  Widget _buildStepLayout({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.abledFont,
            ),
          ),
          const SizedBox(height: 20),
          // 입력창 부분만 AnimatedBuilder로 감쌉니다.
          AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              // elasticIn 커브와 Offset을 조합해 좌우로 흔듭니다.
              double offset = 0.0;
              if (_shakeController.isAnimating) {
                // 사인 함수를 이용해 좌우 왕복 효과 (dart:math 임포트 필요)
                offset = 8 * Math.sin(_shakeController.value * 4 * Math.pi);
              }
              return Transform.translate(
                offset: Offset(offset, 0),
                child: child,
              );
            },
            child: child,
          ),
        ],
      ),
    );
  }
}
