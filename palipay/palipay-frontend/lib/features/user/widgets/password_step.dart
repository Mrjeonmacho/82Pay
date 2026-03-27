// lib/features/user/widgets/password_step.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'step_layout.dart';
import '../../../core/widgets/widgets.dart';
import '../provider/sign_up_provider.dart';

class PasswordStep extends StatelessWidget {
  final AnimationController shakeController;

  const PasswordStep({super.key, required this.shakeController});

  @override
  Widget build(BuildContext context) {
    // 🚀 watch를 사용하여 Provider의 상태 변화를 실시간으로 UI에 반영
    final provider = context.watch<SignUpProvider>();
    final screenHeight = MediaQuery.of(context).size.height;
    final spacing = screenHeight * 0.02;
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.only(bottom: keyboardOpen ? 120 : 24),
      child: Column(
        children: [
          // 1. 비밀번호 입력 영역
          StepLayout(
            title: 'sign_up.password'.tr(),
            shakeController: shakeController,
            child: PaliInputField(
              hintText: 'sign_up.hint_set_password'.tr(),
              controller: provider.passwordController,
              isPassword: true,
              // 🚀 입력할 때마다 실시간 검증 호출
              onChanged: (_) => provider.checkPasswordLogic(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'sign_up.error_empty_password'.tr();
                }
                // 🚀 보안 규칙 미준수 시 에러
                if (!provider.isPasswordSecure) {
                  return 'sign_up.error_invalid_password'.tr();
                }
                return null;
              },
            ),
          ),

          SizedBox(height: spacing),

          // 2. 비밀번호 확인 영역
          StepLayout(
            title: 'sign_up.confirm_password'.tr(),
            shakeController: shakeController,
            child: PaliInputField(
              hintText: 'sign_up.hint_confirm_password'.tr(),
              controller: provider.confirmPasswordController,
              isPassword: true,
              // 🚀 입력할 때마다 실시간 검증 호출
              onChanged: (_) => provider.checkPasswordLogic(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'sign_up.error_empty_confirm_password'.tr();
                }
                // 🚀 불일치 시 에러
                if (!provider.isPasswordMatch) {
                  return 'sign_up.error_password_mismatch'.tr();
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}
