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

class _SignUpScreenState extends State<SignUpScreen> {
  // 페이지 이동을 제어하기 위한 컨트롤러
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // 각 단계에서 입력받을 데이터를 저장할 변수들
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _authCodeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    // 메모리 누수 방지를 위해 컨트롤러들을 해제합니다.
    _pageController.dispose();
    _emailController.dispose();
    _authCodeController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 다음 단계로 이동하는 함수
  void _onNextPressed() {
    if (_currentIndex < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // 1. 여기서 실제 가입 API를 호출하겠죠?
      // 2. 가입 성공 시 아래 코드로 화면 전환
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignUpSuccessScreen()),
      );
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

            // ... Column 내부
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  Text('Create Your Account', style: AppTextStyles.titleLarge),
                  const SizedBox(height: 25), // 여백 확보
                  // --- 커스텀 스텝 진행 바 시작 ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStepItem(0, '이메일 입력'),
                      _buildStepLine(0),
                      _buildStepItem(1, '이메일 확인'),
                      _buildStepLine(1),
                      _buildStepItem(2, '프로필 설정'),
                      _buildStepLine(2),
                      _buildStepItem(3, '비밀번호'),
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

  // 1. 이메일 입력
  Widget _buildEmailStep() {
    return _buildStepLayout(
      title: 'Email',
      child: PaliInputField(
        hintText: 'Enter your email',
        controller: _emailController,
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
          title: 'Set Password',
          child: PaliInputField(
            hintText: 'Password',
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
          child,
        ],
      ),
    );
  }
}
