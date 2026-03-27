// lib/core/widgets/bank_selection_sheet.dart

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/bank_constants.dart'; // 아까 만든 상수 파일
import 'package:easy_localization/easy_localization.dart';

class BankSelectionSheet extends StatelessWidget {
  final String countryCode; // 'KR', 'US' 등 국가 코드
  final Function(Map<String, dynamic>) onSelect; // 선택 시 실행할 콜백

  const BankSelectionSheet({
    super.key,
    required this.countryCode,
    required this.onSelect,
  });

  double _clamp(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    // 1. 해당 국가의 은행 목록과 통화 정보 가져오기
    final banks = BankConstants.getBanks(countryCode);

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    final sheetHeight = _clamp(height * 0.72, 480, height * 0.82);
    final horizontalPadding = _clamp(width * 0.05, 18, 24);

    final sheetRadius = _clamp(width * 0.08, 24, 32);
    final handleWidth = _clamp(width * 0.10, 36, 46);
    final handleHeight = _clamp(height * 0.006, 4, 6);

    final topGap = _clamp(height * 0.015, 10, 14);
    final handleBottomGap = _clamp(height * 0.03, 20, 30);
    final titleBottomGap = _clamp(height * 0.025, 18, 26);
    final gridBottomPadding = safeBottom + _clamp(height * 0.02, 14, 22);

    final titleFontSize = _clamp(width * 0.06, 24, 32);

    final gridMainSpacing = _clamp(width * 0.03, 12, 16);
    final gridCrossSpacing = _clamp(width * 0.03, 12, 16);
    final childAspectRatio = width < 360 ? 0.82 : 0.88;

    return Container(
      height: sheetHeight, // 여기서 이미 높이를 고정했기 때문에 Expanded를 쓸 수 있습니다.
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(sheetRadius)),
      ),
      // 🚀 수정: SingleChildScrollView를 제거했습니다.
      child: Column(
        children: [
          SizedBox(height: topGap),
          // 핸들러 바
          Container(
            width: handleWidth,
            height: handleHeight,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          SizedBox(height: handleBottomGap),

          Text(
            'bank.selection.title'.tr(namedArgs: {'country': countryCode}),
            style: AppTextStyles.titleMedium.copyWith(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w800,
              color: AppColors.abledFont,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: titleBottomGap),

          // 🚀 이제 Column 안의 Expanded가 정상 작동합니다.
          // GridView가 남은 공간을 꽉 채우고 내부에서 스크롤됩니다.
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.only(bottom: gridBottomPadding),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: gridMainSpacing,
                crossAxisSpacing: gridCrossSpacing,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: banks.length,
              itemBuilder: (context, index) {
                final bank = banks[index];
                return _buildBankItem(context, bank, width, height);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankItem(
    BuildContext context,
    Map<String, dynamic> bank,
    double screenWidth,
    double screenHeight,
  ) {
    final itemRadius = _clamp(screenWidth * 0.05, 16, 20);
    final itemPaddingH = _clamp(screenWidth * 0.025, 8, 12);
    final itemPaddingV = _clamp(screenHeight * 0.018, 12, 16);

    final logoSize = _clamp(screenWidth * 0.10, 34, 44);
    final logoTextGap = _clamp(screenHeight * 0.015, 10, 14);

    double labelFontSize = _clamp(screenWidth * 0.05, 15, 18);

    if (countryCode != 'KR') {
      labelFontSize = _clamp(screenWidth * 0.05, 11, 14);
    }

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onSelect(bank);
      },
      borderRadius: BorderRadius.circular(itemRadius),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF6F6F8),
          borderRadius: BorderRadius.circular(itemRadius),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: itemPaddingH,
          vertical: itemPaddingV,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              bank['logo'],
              width: logoSize,
              height: logoSize,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.account_balance, size: logoSize),
            ),
            SizedBox(height: logoTextGap),
            Text(
              bank['name'],
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: labelFontSize,
                fontWeight: FontWeight.w600,
                color: AppColors.abledFont,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
