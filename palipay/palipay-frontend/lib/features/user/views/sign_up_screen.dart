import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';

// 분리한 위젯 및 프로바이더 임포트
import '../provider/sign_up_provider.dart';
import '../widgets/email_step.dart';
import '../widgets/email_auth_step.dart';
import '../widgets/profile_step.dart';
import '../widgets/password_step.dart';
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
  final _formKey = GlobalKey<FormState>();
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  // 다음 버튼 클릭 로직
  void _onNextPressed(SignUpProvider provider) {
    // 1. 이메일 단계 특수 검증 (중복 체크)
    if (provider.currentIndex == 0 &&
        (!provider.isEmailAvailable || provider.isCheckingEmail)) {
      _shakeController.forward(from: 0.0);
      return;
    }

    // 2. 폼 유효성 검사 (Step 위젯들의 validator 호출)
    if (_formKey.currentState!.validate()) {
      if (provider.currentIndex < 3) {
        provider.setCurrentIndex(provider.currentIndex + 1);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        // 성공 시 이동
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
    // ⭐️ Provider 구독: 데이터 창고와 연결
    final provider = Provider.of<SignUpProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: provider.currentIndex > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  provider.setCurrentIndex(provider.currentIndex - 1);
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              )
            : null,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 1. 로고
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Image.asset(
                  'assets/images/logos/palilogo1.png',
                  height: 100,
                ),
              ),

              // 2. 타이틀 및 스텝 바
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    Text(
                      'Create Your Account',
                      style: AppTextStyles.titleLarge,
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStepItem(0, 'Email', provider),
                        _buildStepLine(0, provider),
                        _buildStepItem(1, 'Confirm', provider),
                        _buildStepLine(1, provider),
                        _buildStepItem(2, 'Profile', provider),
                        _buildStepLine(2, provider),
                        _buildStepItem(3, 'Password', provider),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 3. 단계별 콘텐츠 (PageView)
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    EmailStep(shakeController: _shakeController),
                    EmailAuthStep(shakeController: _shakeController),
                    ProfileStep(shakeController: _shakeController),
                    PasswordStep(shakeController: _shakeController),
                  ],
                ),
              ),

              // 4. 하단 버튼
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: PaliButton(
                  text: provider.currentIndex == 3 ? 'Sign Up' : 'Next',
                  onPressed: () => _onNextPressed(provider),
                  backgroundColor: AppColors.mainBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 스텝 바 위젯 (내부 유지) ---
  Widget _buildStepItem(int index, String label, SignUpProvider provider) {
    bool isCurrent = provider.currentIndex == index;
    bool isDone = provider.currentIndex > index;

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
                ? Border.all(color: AppColors.mainBlue, width: 4)
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
                          : Colors.black38,
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
            color: isCurrent ? AppColors.mainBlue : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int index, SignUpProvider provider) {
    bool isDone = provider.currentIndex > index;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 2,
        color: isDone ? AppColors.mainBlue : AppColors.disabledBackground,
      ),
    );
  }
}
