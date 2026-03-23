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

  @override
  Widget build(BuildContext context) {
    // 1. 해당 국가의 은행 목록과 통화 정보 가져오기
    final banks = BankConstants.getBanks(countryCode);
    final currency = BankConstants.getDefaultCurrency(countryCode);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7, // 화면 높이의 70%
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // 핸들러 바
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          
          Text(
            'bank.selection.title'.tr(namedArgs: {
              'country': countryCode,
              'currency': currency,
            }),
            style: AppTextStyles.titleMedium,
          ),

          const SizedBox(height: 24),

          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: banks.length,
              itemBuilder: (context, index) {
                final bank = banks[index];
                return _buildBankItem(context, bank);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankItem(BuildContext context, Map<String, dynamic> bank) {
    return InkWell(
      onTap: () {
        onSelect(bank); // 선택된 은행 전체 데이터를 부모에게 전달
        Navigator.pop(context); // 시트 닫기
      },
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 2. 아까 정리한 영어 파일명 로고 적용
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              bank['logo'],
              width: 32,
              height: 32,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_balance),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bank['name'],
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}