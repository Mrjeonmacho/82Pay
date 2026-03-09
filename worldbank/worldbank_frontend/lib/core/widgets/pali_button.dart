import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum PaliButtonType { primary, point }

class PaliButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final PaliButtonType type;

  const PaliButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = PaliButtonType.primary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56, //
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: type == PaliButtonType.primary
              ? AppColors.mainBlue
              : AppColors.warningRed, //
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(text, style: AppTextStyles.labelLarge), //
      ),
    );
  }
}
