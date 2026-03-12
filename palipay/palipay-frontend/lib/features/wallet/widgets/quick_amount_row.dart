import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class QuickAmountRow extends StatelessWidget {
  final Function(double) onAmountSelected;

  const QuickAmountRow({super.key, required this.onAmountSelected});

  @override
  Widget build(BuildContext context) {
    // 와이어프레임 기준 금액 단위
    final List<int> amounts = [10000, 30000, 50000, 100000];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: amounts.map((amount) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => onAmountSelected(amount.toDouble()),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.abledFont),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${amount ~/ 10000}만',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.mainBlue,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
