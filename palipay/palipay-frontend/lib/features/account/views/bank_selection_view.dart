import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';

class BankSelectionView extends StatelessWidget {
  const BankSelectionView({super.key});

  // 1. 샘플 은행 데이터 리스트 (실제로는 API나 상수로 관리 권장)
  // 일단 하드코딩
  final List<Map<String, String>> banks = const [
    {'name': 'Pali Bank', 'code': 'PALI', 'logo': '🏦'},
    {'name': 'World Bank', 'code': 'WRLD', 'logo': '🌎'},
    {'name': 'Kookmin', 'code': '004', 'logo': '💛'},
    {'name': 'Shinhan', 'code': '088', 'logo': '💙'},
    {'name': 'Woori', 'code': '020', 'logo': '💎'},
    {'name': 'Hana', 'code': '081', 'logo': '💚'},
    {'name': 'Toss', 'code': '092', 'logo': '🔵'},
    {'name': 'Kakao', 'code': '090', 'logo': '💛'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PaliTopBar(title: 'Select Bank'), // 공통 상단바 적용
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text(
                'Which bank would you like\nto link?',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3열 그리드 구성
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.9,
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
      ),
    );
  }

  // 2. 개별 은행 아이템 위젯
  Widget _buildBankItem(BuildContext context, Map<String, String> bank) {
    return InkWell(
      onTap: () {
        // 7번 화면인 AccountLinkView로 선택한 데이터 전달
        Navigator.pushNamed(
          context,
          '/account-link',
          arguments: {'bankName': bank['name'], 'bankCode': bank['code']},
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.disabledBackground),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(bank['logo']!, style: const TextStyle(fontSize: 32)), // 로고 아이콘
            const SizedBox(height: 8),
            Text(
              bank['name']!,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
