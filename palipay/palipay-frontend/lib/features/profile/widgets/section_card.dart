import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SectionCard extends StatelessWidget {
final String title;
final List<Widget> children;

const SectionCard({
  super.key,
  required this.title,
  required this.children,
});

@override
Widget build(BuildContext context) {
  return Container(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.mainBlue,
          ),
        ),
        const SizedBox(height: 14),
        ...children,
      ],
    ),
  );
}
}