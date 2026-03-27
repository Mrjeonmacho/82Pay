// lib/features/user/views/login_screen.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers & Models
import 'package:palipay_app/features/user/provider/login_provider.dart';
import 'package:palipay_app/core/providers/user_provider.dart';

// Views
import 'package:palipay_app/features/user/views/sign_up_screen.dart';
import 'package:palipay_app/main_screen.dart';

// Widgets & Theme
import 'package:palipay_app/features/user/widgets/step_layout.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final provider = context.read<LoginProvider>();

      // 1. 자동 로그인 여부 확인
      bool canLoginSilently = await provider.trySilentLogin();
      if (canLoginSilently && mounted) {
        // 이미 main.dart에서 UserProvider가 체크하지만, 이중 방어로 유지
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }

      // 2. 비밀번호 변경 성공 메시지 처리
      if (widget.showPasswordChangedMessage) {
        provider.triggerPasswordChangedMessage();
      }
    });

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _shake() {
    _shakeController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    // watch를 사용하여 상태 변화를 감지
    final provider = context.watch<LoginProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),
                    Text(
                      'login.welcome'.tr(),
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.mainBlue,
                        fontSize: 28,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // 입력 영역
                    StepLayout(
                      title: '',
                      shakeController: _shakeController,
                      child: Column(
                        children: [
                          PaliInputField(
                            hintText: 'login.hint_email'.tr(),
                            controller: provider.emailController,
                            maxLength: 50,
                            showCounter: false,
                            highlightMaxLength: true,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          PaliInputField(
                            hintText: 'login.hint_password'.tr(),
                            controller: provider.passwordController,
                            maxLength: 50,
                            showCounter: false,
                            highlightMaxLength: true,
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
                          // 에러 메시지
                          if (provider.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                provider.errorMessage!.tr(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                          // 자동 로그인 체크
                          Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: provider.isAutoLogin,
                                  onChanged: (value) =>
                                      provider.setAutoLogin(value ?? false),
                                  activeColor: AppColors.mainBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => provider.setAutoLogin(
                                  !provider.isAutoLogin,
                                ),
                                child: Text(
                                  'login.auto_login'.tr(),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

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
                                          builder: (_) => const MainScreen(),
                                        ),
                                      );
                                    } else {
                                      _shake();
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.mainBlue,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: AppColors.mainBlue
                                  .withOpacity(0.5),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: provider.isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    'login.btn_login'.tr(),
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),

                          const SizedBox(height: 24),

                          // 회원가입 링크
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SignUpScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'sign_up.create_your_account'.tr(),
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

  Widget _buildPasswordChangedOverlay() {
    return IgnorePointer(
      child: Align(
        alignment: const Alignment(0, -0.85),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.mainBlue,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            'login.password_changed_msg'.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}
