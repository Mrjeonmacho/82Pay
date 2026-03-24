import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class QuickAmountRow extends StatelessWidget {
  final Function(double) onAmountSelected;

  const QuickAmountRow({super.key, required this.onAmountSelected});

  String _formatWon(int amount) {
    final text = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final reverseIndex = text.length - i - 1;
      buffer.write(text[i]);
      if (reverseIndex % 3 == 0 && i != text.length - 1) {
        buffer.write(',');
      }
    }
    return '${buffer.toString()}₩';
  }

  @override
  Widget build(BuildContext context) {
    // 와이어프레임 기준 금액 단위
    final List<int> amounts = [10000, 30000, 50000, 100000];

    return Row(
      children: amounts.asMap().entries.map((entry) {
        final isLast = entry.key == amounts.length - 1;
        final amount = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 8.0),
            child: InkWell(
              onTap: () => onAmountSelected(amount.toDouble()),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0), // light gray pill
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '+${_formatWon(amount)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.abledFont,
                      fontSize: 12,
                    ),
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
