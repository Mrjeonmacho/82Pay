import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/pali_bank_selection_sheet.dart';
import '../../account/views/account_link_view.dart';
import 'dashed_rect_painter.dart';

class EmptyWalletCard extends StatelessWidget {
  const EmptyWalletCard({super.key});

  @override
  Widget build(BuildContext context) {
    context.locale; // 다국어 반영

    return InkWell(
      onTap: () {
        _openBankSelection(context);
      },
      borderRadius: BorderRadius.circular(24),
      child: CustomPaint(
        painter: DashedRectPainter(color: AppColors.exampleFont),
        child: SizedBox(
          width: double.infinity,
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_circle_outline,
                size: 48,
                color: AppColors.mainBlue,
              ),
              const SizedBox(height: 12),
              Text(
                'linked_accounts.link_bank_account'.tr(),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.abledFont,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 실제 연동 로직을 위해 은행 선택 바텀시트를 엽니다.
  void _openBankSelection(BuildContext context) {
    final userCountry = context.read<UserProvider>().countryCode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BankSelectionSheet(
        countryCode: userCountry ?? 'US', // 유저의 실제 국가 코드 사용
        onSelect: (selectedBank) {
          // 1. BankSelectionSheet 내부에서 자동으로 pop() 하므로 생략
          
          // 2. 계좌번호 및 이름 입력(AccountLinkView) 화면으로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AccountLinkView(
                bankName: selectedBank['name'] ?? '',
                bankCode: selectedBank['bankCode'] ?? '',
              ),
            ),
          );
        },
      ),
    );
  }
}
