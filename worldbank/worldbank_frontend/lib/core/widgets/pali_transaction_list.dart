import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class PaliTransactionList extends StatelessWidget {
  final String storeName;
  final String amount;
  final String time;
  final bool isCharge; // 충전 여부

  const PaliTransactionList({
    super.key,
    required this.storeName,
    required this.amount,
    required this.time,
    this.isCharge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(storeName, style: AppTextStyles.bodyLarge), //
              Text(
                time,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: const Color(0xFF524848),
                ),
              ),
            ],
          ),
          Text(
            '${isCharge ? "+" : "-"}$amount',
            style: AppTextStyles.bodyLarge.copyWith(
              color: isCharge
                  ? const Color(0xFF2426D3)
                  : AppColors.abledFont, //
            ),
          ),
        ],
      ),
    );
  }
}
