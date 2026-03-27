// widgets/email_step.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/widgets.dart';
import 'step_layout.dart';

// provider 임포트
import '../provider/sign_up_provider.dart';
import 'package:provider/provider.dart';

class EmailStep extends StatelessWidget {
  final AnimationController shakeController;

  const EmailStep({super.key, required this.shakeController});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SignUpProvider>(context);
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      physics: const ClampingScrollPhysics(), // [추가] 불필요하게 늘어지는 스크롤 느낌 완화
      padding: EdgeInsets.only(
        bottom: keyboardOpen ? 120 : 24, // [수정] 키보드 있을 때만 하단 여백 크게
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepLayout(
            title: 'sign_up.step_email'.tr(),
            shakeController: shakeController,
            child: PaliInputField(
              hintText: 'sign_up.hint_email'.tr(),
              controller: provider.emailController,
              maxLength: 50,
              showCounter: true,
              highlightMaxLength: true,
              onChanged: (value) => provider.checkEmailAvailability(),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              suffixIcon: provider.isCheckingEmail
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : (provider.isEmailAvailable && provider.isEmailValid
                      ? const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        )
                      : null),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter your email';
                }
                if (!provider.isEmailValid) {
                  return 'Invalid email address.';
                }
                if (!provider.isCheckingEmail && !provider.isEmailAvailable) {
                  return 'This email is already taken.';
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
