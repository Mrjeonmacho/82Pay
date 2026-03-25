// 결과 완료 화면
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart'; // PaliButton 등
import '../../../core/utils/currency_input_formatter.dart';

class WalletResultView extends StatelessWidget {
  final bool isRecharge; // 충전인지 환불인지 구분
  final String amount; // 표시할 금액 (예: "₩ 1417" 또는 "$ 1417")

  const WalletResultView({
    super.key,
    required this.isRecharge,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // 1. 체크 아이콘 (와이어프레임 반영)
              const Icon(Icons.check, size: 80, color: AppColors.abledFont),
              const SizedBox(height: 40),

              // 2. 금액 및 상태 텍스트
              Text(
                amount,
                style: AppTextStyles.headlineLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.mainBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isRecharge ? 'common.add_money'.tr() : 'common.cash_out'.tr(),
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.abledFont,
                ),
              ),

              const Spacer(),

              // 3. 확인 버튼 (메인으로 이동)
              PaliButton(
                backgroundColor: AppColors.mainBlue,
                text: 'common.ok'.tr(),
                onPressed: () {
                  // 모든 화면을 닫고 홈(메인)으로 돌아갑니다.
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
