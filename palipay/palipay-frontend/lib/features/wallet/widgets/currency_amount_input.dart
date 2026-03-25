import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_input_formatter.dart';
import '../providers/wallet_provider.dart';

class CurrencyAmountInput extends StatelessWidget {
  final String label; // "AMOUNT TO TOP-UP" 또는 "AMOUNT TO REFUND"
  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String> onChanged; // String을 인자로 받도록 수정

  const CurrencyAmountInput({
    super.key,
    required this.label,
    required this.controller,
    required this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    // 실시간 환율 정보를 그리기 위해 provider 구독
    final provider = context.watch<WalletProvider>();

    return Column(
      children: [
        // 1. 상단 라벨 (와이어프레임 1번 반영)
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.abledFont,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),

        // 2. 메인 금액 입력창 (KRW 기준)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            // IntrinsicWidth를 써야 글자 수에 맞춰 TextField 너비가 조절되어 가운데 정렬이 유지됩니다.
            IntrinsicWidth(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()], // 기존 유틸 사용
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineLarge.copyWith(
                  fontSize: 48,
                  color: AppColors.mainBlue,
                  fontWeight: FontWeight.w900,
                ),
                decoration: const InputDecoration(
                  hintText: '0',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: AppColors.abledFont),
                  isDense: true, // 불필요한 패딩 제거
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'KRW',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.abledFont,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 3. 실시간 환전 정보 (환산 금액 + 기준 환율)
        Column(
          children: [
            // (1) 외화 환산 금액 배지
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sync, size: 16, color: AppColors.abledFont),
                  const SizedBox(width: 8),
                  Text(
                    '≈ ${provider.foreignAmount.toStringAsFixed(2)} ${provider.targetCurrency}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.abledFont,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            
            // (2) 실시간 기준 환율 및 가져온 시각 (서버 연동 표시)
            if (provider.rateTimestamp != null)
              Builder(
                builder: (context) {
                  // 서버에서 오는 포맷 "2026-03-05T14:00:00+09:00" -> 이쁘게 변환
                  try {
                    final dt = DateTime.parse(provider.rateTimestamp!);
                    final formattedTime = DateFormat('yyyy.MM.dd HH:mm').format(dt);
                    return Text(
                      '1 ${provider.targetCurrency} = ${provider.exchangeRate.toStringAsFixed(2)} KRW\n($formattedTime 기준)',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.mainBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    );
                  } catch (e) {
                    return const SizedBox.shrink();
                  }
                },
              ),
          ],
        ),
      ],
    );
  }
}
