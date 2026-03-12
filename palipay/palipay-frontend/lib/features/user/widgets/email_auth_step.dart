import 'package:flutter/material.dart';
import 'step_layout.dart';
import '../../../core/widgets/widgets.dart';

// provider 임포트
import '../provider/sign_up_provider.dart';
import 'package:provider/provider.dart';

class EmailAuthStep extends StatelessWidget {
  final AnimationController shakeController;

  const EmailAuthStep({super.key, required this.shakeController});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SignUpProvider>(context);
    return StepLayout(
      title: 'Verification Code',
      shakeController: shakeController,
      child: PaliInputField(
        hintText: 'Enter 6-digit code',
        controller: provider.authCodeController,
        keyboardType: TextInputType.number,
        maxLength: 6, // 6자리 제한
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter the verification code.';
          }
          if (value.length < 6) {
            return 'The code must be 6 digits.';
          }
          return null;
        },
      ),
    );
  }
}
