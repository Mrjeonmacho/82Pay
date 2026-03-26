import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final screenHeight = MediaQuery.of(context).size.height;
    final spacing = screenHeight * 0.02;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        children: [
          StepLayout(
            title: 'sign_up.name'.tr(),
            shakeController: shakeController,
            child: PaliInputField(
              hintText: 'sign_up.hint_name'.tr(),
              controller: provider.nameController,
              validator: (value) =>
                  value!.isEmpty ? 'sign_up.error_empty_name'.tr() : null,
            ),
          ),
          SizedBox(height: spacing),
          StepLayout(
            title: 'sign_up.phone_number'.tr(),
            shakeController: shakeController,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 3,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.disabledBackground),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: provider.selectedCountryCode,
                        items: const [
                          DropdownMenuItem(value: '+1', child: Text('🇺🇸 +1')),
                          DropdownMenuItem(
                            value: '+86',
                            child: Text('🇨🇳 +86'),
                          ),
                          DropdownMenuItem(
                            value: '+81',
                            child: Text('🇯🇵 +81'),
                          ),
                        ],
                        onChanged: (value) => provider.setCountryCode(value!),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: spacing),
                Flexible(
                  flex: 4,
                  child: PaliInputField(
                    hintText: 'sign_up.hint_phone_number'.tr(),
                    controller: provider.phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ], // 숫자만 입력 가능
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter phone number';
                      }
                      if (value.length < 7) return 'Phone number is too short';
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.2),
        ],
      ),
    );
  }
}
