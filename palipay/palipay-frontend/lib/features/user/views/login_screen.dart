import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:palipay_app/features/user/provider/login_provider.dart';
import 'package:palipay_app/features/user/views/sign_up_screen.dart';
import 'package:palipay_app/features/user/widgets/step_layout.dart';
import 'package:palipay_app/main_screen.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/pali_input_field.dart';

class LoginScreen extends StatefulWidget {
  final bool showPasswordChangedMessage;

  const LoginScreen({super.key, this.showPasswordChangedMessage = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    // 화면이 뜨자마자 Provider에게 물어봅니다.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<LoginProvider>();

      // ⭐️ 로직은 Provider가, 화면 이동은 Screen이!
      bool canLoginSilently = await provider.trySilentLogin();

      if (canLoginSilently && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    });

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    // 화면이 뜨자마자 메시지 표시 여부 확인
    if (widget.showPasswordChangedMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<LoginProvider>().triggerPasswordChangedMessage();
      });
    }
  }

  @override
  void dispose() {
    // ⭐️ 4. 컨트롤러 dispose 필수!
    _shakeController.dispose();
    super.dispose();
  }

  // ⭐️ 5. 흔들기 실행 함수 (ProfileStep 등과 동일 로직)
  void _shake() {
    _shakeController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LoginProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(backgroundColor: AppColors.background, elevation: 0),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 80),
                    Text(
                      'login.welcome'.tr(),
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.mainBlue, // 앱 기본 텍스트 색상
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    // 이메일 입력창
                    // 1. 이메일 입력 (Provider 연결)
                    StepLayout(
                      title: '', // 또는 원하는 문구
                      shakeController: _shakeController,
                      child: Column(
                        children: [
                          PaliInputField(
                            hintText: 'Email',
                            controller: provider.emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          PaliInputField(
                            hintText: 'Password',
                            controller: provider.passwordController,
                            isPassword: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 24),

                          // 에러 메시지
                          if (provider.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                provider.errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: provider
                                      .isAutoLogin, // Provider에 변수 추가 필요
                                  onChanged: (value) {
                                    provider.setAutoLogin(value ?? false);
                                  },
                                  activeColor: AppColors.mainBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => provider.setAutoLogin(
                                  !provider.isAutoLogin,
                                ),
                                child: Text(
                                  'Auto Login',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // 로그인 버튼
                          ElevatedButton(
                            onPressed: provider.isLoading
                                ? null
                                : () async {
                                    bool success = await provider.login(
                                      context,
                                    );
                                    if (success && mounted) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const MainScreen(),
                                        ),
                                      );
                                    } else {
                                      _shake();
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.mainBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: provider.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Login',
                                    style: AppTextStyles.labelLarge,
                                  ),
                          ),

                          const SizedBox(height: 15),

                          // 구분선 (Or)
                          // const Row(
                          //   children: [
                          //     Expanded(
                          //       child: Divider(color: AppColors.mainBlue),
                          //     ),
                          //     Padding(
                          //       padding: EdgeInsets.symmetric(
                          //         horizontal: 20,
                          //         vertical: 10,
                          //       ),
                          //       child: Text(
                          //         'Or',
                          //         style: AppTextStyles.bodySmall,
                          //       ),
                          //     ),
                          //     Expanded(
                          //       child: Divider(color: AppColors.mainBlue),
                          //     ),
                          //   ],
                          // ),

                          // const SizedBox(height: 15),

                          // 구글 로그인 버튼
                          // OutlinedButton(
                          //   onPressed: () {},
                          //   style: OutlinedButton.styleFrom(
                          //     padding: const EdgeInsets.symmetric(vertical: 15),
                          //     side: const BorderSide(color: AppColors.mainBlue),
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(8),
                          //     ),
                          //   ),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.center,
                          //     children: [
                          //       Image.asset(
                          //         'assets/images/logos/google.png',
                          //         height: 24,
                          //       ),
                          //       const SizedBox(width: 12),
                          //       Text(
                          //         'Continue with Google',
                          //         style: AppTextStyles.bodyLarge.copyWith(
                          //           color: AppColors.mainBlue,
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          const SizedBox(height: 12),

                          // 회원가입 안내
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SignUpScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Sign Up',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.mainBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (provider.showOverlayMessage) _buildPasswordChangedOverlay(),
          ],
        ),
      ),
    );
  }

  // 오버레이 위젯 추출 (가독성용)
  Widget _buildPasswordChangedOverlay() {
    return IgnorePointer(
      child: Align(
        alignment: const Alignment(0, -0.8),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.mainBlue,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Text(
            'Your password has been changed successfully. Please log in again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}
