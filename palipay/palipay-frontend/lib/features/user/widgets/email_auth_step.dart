import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:palipay_app/core/theme/app_colors.dart';
import 'step_layout.dart';
import '../../../core/widgets/widgets.dart';

// provider 임포트
import '../provider/sign_up_provider.dart';
import 'package:provider/provider.dart';

// widgets/email_auth_step.dart

class EmailAuthStep extends StatelessWidget {
  final AnimationController shakeController;

  const EmailAuthStep({super.key, required this.shakeController});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SignUpProvider>(context);

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: StepLayout(
        title: 'sign_up.verification_code'.tr(),
        shakeController: shakeController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PaliInputField(
              hintText: 'Enter 6-digit code',
              controller: provider.authCodeController,
              maxLength: 6,
              // 1. 타이머 표시 (우측 아이콘 자리에 배치)
              suffixIcon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                child: Text(
                  provider.timerText, // 02:59 형식
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the verification code.';
                }
                if (value.length < 6) return 'The code must be 6 digits.';
                // 2. 시간이 만료되었을 때 에러 처리 (선택사항)
                if (provider.authSecondsRemaining == 0) {
                  return 'Verification code expired.';
                }
                return null;
              },
            ),

            // 3. 재발송 버튼 섹션
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  "Didn't receive the code? ",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                TextButton(
                  onPressed: provider.authSecondsRemaining > 175
                      ? null
                      : () => provider.resendAuthCode(),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: Text(
                    'Resend',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: provider.authSecondsRemaining > 175
                          ? AppColors.disabledFont
                          : AppColors.mainBlue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
