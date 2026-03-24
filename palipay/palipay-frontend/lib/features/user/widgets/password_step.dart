import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'step_layout.dart';
import '../../../core/widgets/widgets.dart';

// provider 임포트
import '../provider/sign_up_provider.dart';
import 'package:provider/provider.dart';

class PasswordStep extends StatelessWidget {
  final AnimationController shakeController;

  const PasswordStep({super.key, required this.shakeController});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SignUpProvider>(context);

    return Column(
      children: [
        StepLayout(
          title: 'sign_up.password'.tr(),
          shakeController: shakeController,
          child: PaliInputField(
            hintText: 'sign_up.hint_set_password'.tr(),
            controller: provider.passwordController, // ✅ 올바른 컨트롤러 연결
            isPassword: true,
            onChanged: (_) => provider.checkPasswordLogic(), // ✅ 입력할 때마다 로직 실행
            validator: (value) {
              if (value == null || value.isEmpty) return 'sign_up.error_empty_password'.tr();

              // 8자리 이상, 영문, 숫자, 특수문자 포함 여부 확인
              if (!provider.isPasswordSecure) {
                return 'sign_up.error_invalid_password'.tr();
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 16),
        StepLayout(
          title: 'sign_up.confirm_password'.tr(),
          shakeController: shakeController,
          child: PaliInputField(
            hintText: 'sign_up.hint_confirm_password'.tr(),
            controller: provider.confirmPasswordController, // ✅ 올바른 컨트롤러 연결
            isPassword: true,
            onChanged: (_) => provider.checkPasswordLogic(), // ✅ 입력할 때마다 로직 실행
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'sign_up.error_empty_confirm_password'.tr();
              }
              if (!provider.isPasswordMatch) {
                return 'sign_up.error_password_mismatch'.tr();
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
