import 'dart:math' as Math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class StepLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final AnimationController shakeController;

  const StepLayout({
    super.key,
    required this.title,
    required this.child,
    required this.shakeController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.abledFont,
            ),
          ),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: shakeController,
            builder: (context, child) {
              double offset = 0.0;
              if (shakeController.isAnimating) {
                offset = 8 * Math.sin(shakeController.value * 4 * Math.pi);
              }
              return Transform.translate(
                offset: Offset(offset, 0),
                child: child,
              );
            },
            child: child,
          ),
        ],
      ),
    );
  }
}
