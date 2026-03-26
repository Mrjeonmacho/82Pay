// 출/입금 계좌 정보 카드 위젯 (WalletAccountCard)
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class WalletAccountCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? iconWidget; // 💡 아이콘 대신 이미지가 필요한 경우를 대비한 유연한 옵s션
  final Widget? trailing; // 화살표나 체크박스 등 상황에 맞게 배치

  const WalletAccountCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconWidget,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 아이콘 영역 (스타일 가이드 반영)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                iconWidget ??
                const Icon(Icons.account_balance, color: AppColors.mainBlue),
          ),
          const SizedBox(width: 16),
          // 텍스트 영역
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.mainBlue,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.abledFont,
                  ),
                ),
              ],
            ),
          ),
          // 우측 아이콘 (상황에 따라 유동적)
          ?trailing,
        ],
      ),
    );
  }
}
