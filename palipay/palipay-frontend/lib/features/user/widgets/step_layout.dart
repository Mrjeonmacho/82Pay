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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.abledFont,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
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
