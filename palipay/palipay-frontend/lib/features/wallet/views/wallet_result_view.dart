// lib/features/wallet/views/wallet_result_view.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';

class WalletResultView extends StatelessWidget {
  final bool isRecharge;
  final String amount;

  const WalletResultView({
    super.key,
    required this.isRecharge,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    // 🚀 [보안 추가] PopScope를 사용하여 시스템 뒤로가기 버튼을 막습니다.
    // 결과 화면에 도달했다면 무조건 '확인' 버튼을 통해서만 홈으로 가야 안전합니다.
    return PopScope(
      canPop: false, // 시스템 뒤로가기 비활성화
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // 시스템 뒤로가기를 눌러도 홈으로 보내버립니다.
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // 1. 성공 체크 아이콘
                const Icon(
                  Icons.check_circle_rounded, // 조금 더 세련된 아이콘 추천
                  size: 100,
                  color: AppColors.mainBlue,
                ),
                const SizedBox(height: 32),

                // 2. 금액 및 상태 텍스트
                Text(
                  amount,
                  style: AppTextStyles.headlineLarge.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.mainBlue,
                    fontSize: 36,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isRecharge
                      ? 'common.add_money_success'.tr()
                      : 'common.cash_out_success'.tr(),
                  style: AppTextStyles.titleLarge.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const Spacer(),

                // 3. 확인 버튼 (메인으로 복귀)
                PaliButton(
                  backgroundColor: AppColors.mainBlue,
                  text: 'common.confirm'.tr(),
                  onPressed: () {
                    // ✅ 모든 스택을 제거하고 첫 화면(Main)으로 이동
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
