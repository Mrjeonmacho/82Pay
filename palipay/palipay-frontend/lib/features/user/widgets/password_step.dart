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
          title: 'Password',
          shakeController: shakeController,
          child: PaliInputField(
            hintText: 'Set Password',
            controller: provider.passwordController, // ✅ 올바른 컨트롤러 연결
            isPassword: true,
            onChanged: (_) => provider.checkPasswordLogic(), // ✅ 입력할 때마다 로직 실행
            validator: (value) {
              if (value == null || value.isEmpty) return 'Enter password';

              // 8자리 이상, 영문, 숫자, 특수문자 포함 여부 확인
              if (!provider.isPasswordSecure) {
                return '8+ characters with letters, numbers, and symbols';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 16),
        StepLayout(
          title: 'Confirm Password',
          shakeController: shakeController,
          child: PaliInputField(
            hintText: 'Confirm Password',
            controller: provider.confirmPasswordController, // ✅ 올바른 컨트롤러 연결
            isPassword: true,
            onChanged: (_) => provider.checkPasswordLogic(), // ✅ 입력할 때마다 로직 실행
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Confirm your password';
              }
              // 비밀번호 일치 여부 확인
              if (!provider.isPasswordMatch) {
                return 'Passwords do not match.';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
