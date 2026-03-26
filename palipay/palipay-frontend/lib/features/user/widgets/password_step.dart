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
    final screenHeight = MediaQuery.of(context).size.height;
    final spacing = screenHeight * 0.02;
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.only(
        bottom: keyboardOpen ? 120 : 24,
      ),
      child: Column(
        children: [
          StepLayout(
            title: 'sign_up.password'.tr(),
            shakeController: shakeController,
            child: PaliInputField(
              hintText: 'sign_up.hint_set_password'.tr(),
              controller: provider.passwordController,
              isPassword: true,
              onChanged: (_) => provider.checkPasswordLogic(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'sign_up.error_empty_password'.tr();
                }
                if (!provider.isPasswordSecure) {
                  return 'sign_up.error_invalid_password'.tr();
                }
                return null;
              },
            ),
          ),
          SizedBox(height: spacing),
          StepLayout(
            title: 'sign_up.confirm_password'.tr(),
            shakeController: shakeController,
            child: PaliInputField(
              hintText: 'sign_up.hint_confirm_password'.tr(),
              controller: provider.confirmPasswordController,
              isPassword: true,
              onChanged: (_) => provider.checkPasswordLogic(),
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
      ),
    );
  }
}
