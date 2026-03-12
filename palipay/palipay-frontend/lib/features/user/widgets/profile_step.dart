import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import 'step_layout.dart';

// provider 임포트
import '../provider/sign_up_provider.dart';
import 'package:provider/provider.dart';

// widgets/profile_step.dart
class ProfileStep extends StatelessWidget {
  final AnimationController shakeController;

  const ProfileStep({super.key, required this.shakeController});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SignUpProvider>(context);
    return Column(
      children: [
        StepLayout(
          title: 'Name',
          shakeController: shakeController,
          child: PaliInputField(
            hintText: 'Full Name',
            controller: provider.nameController,
            validator: (value) => value!.isEmpty ? 'Enter your name' : null,
          ),
        ),
        const SizedBox(height: 16),
        StepLayout(
          title: 'Phone Number',
          shakeController: shakeController,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 55,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.disabledBackground),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: provider.selectedCountryCode,
                    items: const [
                      DropdownMenuItem(value: '+1', child: Text('🇺🇸 +1')),
                      DropdownMenuItem(value: '+86', child: Text('🇨🇳 +86')),
                      DropdownMenuItem(value: '+81', child: Text('🇯🇵 +81')),
                    ],
                    onChanged: (value) => provider.setCountryCode(value!),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PaliInputField(
                  hintText: 'Phone Number',
                  controller: provider.phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value!.isEmpty ? 'Enter phone number' : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
