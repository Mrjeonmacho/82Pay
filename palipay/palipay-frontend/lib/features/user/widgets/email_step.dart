// widgets/email_step.dart
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
    return StepLayout(
      title: 'Email',
      shakeController: shakeController,
      child: PaliInputField(
        hintText: 'Enter your email',
        controller: provider.emailController,
        onChanged: (value) => provider.checkEmailAvailability(),
        suffixIcon: provider.isCheckingEmail
            ? const SizedBox(
                width: 20,
                height: 20,
                child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : null,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Enter your email';
          if (!provider.isEmailValid) return 'Invalid email address.';
          if (!provider.isCheckingEmail &&
              !provider.isEmailAvailable &&
              value == 'test@test.com') {
            return 'This email is already taken.';
          }
          return null;
        },
      ),
    );
  }
}
