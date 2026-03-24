import 'package:easy_localization/easy_localization.dart';
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
    // 화면이 생성될 때 데이터를 초기화합니다.
    Future.microtask(() {
      final provider = context.read<SignUpProvider>();

      // 1. 데이터 초기화 (TextController들 비우기)
      provider.resetData();

      // 2. ⭐️ Form 에러 상태 초기화 (빨간 줄 제거)
      // reset()은 모든 필드의 에러 메시지를 지우고 초기 상태로 되돌립니다.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _formKey.currentState?.reset();
      });
    });

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
  void _onNextPressed(SignUpProvider provider) async {
    // --- 1. 이메일 단계(Index 0)일 때 특수 로직 ---
    if (provider.currentIndex == 0) {
      // 아직 중복 체크를 안 했거나 형식이 틀렸다면 체크 함수 실행
      if (!provider.isEmailAvailable) {
        await provider.checkEmailAvailability();
      }

      // 2. 모든 검증 통과 시 페이지 이동
      if (provider.isEmailAvailable && provider.isEmailValid) {
        provider.setCurrentIndex(1);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );

        // 페이지가 넘어가자마자 메일 발송 시작! (기다리지 않고 호출)
        provider.sendEmailCode();
      } else {
        _shakeController.forward(from: 0.0);
      }
      return;
    }

    // --- 3. 인증 코드 단계(Index 1)일 때 ---
    if (provider.currentIndex == 1) {
      // 서버와 코드 검증 통신 (예시)
      bool isCorrect = await provider.verifyEmailCode();

      if (isCorrect) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _shakeController.forward(from: 0.0); // 🫨 흔들기 효과 발동!
        return;
      }
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
        bool success = await provider.finalSignUp(context);
        if (success) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const SignUpSuccessScreen(),
            ),
          );
        } else {
          _shakeController.forward(from: 0.0);
        }
      }
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
                      'sign_up.create_your_account'.tr(),
                      style: AppTextStyles.titleLarge,
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStepItem(0, 'sign_up.step_email'.tr(), provider),
                        _buildStepLine(0, provider),
                        _buildStepItem(1, 'sign_up.step_confirm'.tr(), provider),
                        _buildStepLine(1, provider),
                        _buildStepItem(2, 'sign_up.step_profile'.tr(), provider),
                        _buildStepLine(2, provider),
                        _buildStepItem(3, 'sign_up.step_password'.tr(), provider),
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
                  text: provider.currentIndex == 3 ? 'sign_up.btn_sign_up'.tr() : 'sign_up.btn_next'.tr(),
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
