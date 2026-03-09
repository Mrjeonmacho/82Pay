import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class PaliBalanceCard extends StatelessWidget {
  final String krwAmount;
  final String usdAmount;

  const PaliBalanceCard({
    super.key,
    required this.krwAmount,
    required this.usdAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          //
          colors: [AppColors.warningRed, AppColors.mainBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            krwAmount,
            style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
          ), //
          const SizedBox(height: 8),
          Text(
            '≈ \$$usdAmount',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.8),
            ), //
          ),
        ],
      ),
    );
  }
}
