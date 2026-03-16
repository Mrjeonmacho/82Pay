import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../pin/views/pin_screen.dart';
import 'dashed_rect_painter.dart';

class EmptyWalletCard extends StatelessWidget {
  const EmptyWalletCard({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PinScreen(mode: PinMode.create),
        ),
      ),
      borderRadius: BorderRadius.circular(24),
      child: CustomPaint(
        painter: DashedRectPainter(color: AppColors.exampleFont),
        child: SizedBox(
          width: double.infinity,
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_circle_outline,
                size: 48,
                color: AppColors.mainBlue,
              ),
              const SizedBox(height: 12),
              Text(
                'Link your bank account',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.abledFont,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
