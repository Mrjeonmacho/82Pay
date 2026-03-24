import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class LanguageTrailing extends StatelessWidget {
  final String language;

  const LanguageTrailing({
    super.key,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      language,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.exampleFont,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}