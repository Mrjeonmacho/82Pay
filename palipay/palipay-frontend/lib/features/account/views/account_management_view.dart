import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:palipay_app/core/providers/user_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart'; // PaliTopBar 포함
import '../../pin/views/pin_screen.dart';
import '../../home/widgets/empty_wallet_card.dart';
import '../providers/account_provider.dart';
import '../models/bank_account_model.dart';

class AccountManagementView extends StatefulWidget {
  const AccountManagementView({super.key});

  @override
  State<AccountManagementView> createState() => _AccountManagementViewState();
}

class _AccountManagementViewState extends State<AccountManagementView> {
  @override
  void initState() {
    super.initState();
    // 화면 진입 시 계좌 정보 즉시 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().refreshWalletInfo(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    // watch를 사용하여 계좌 상태 변화를 실시간으로 감지합니다.
    final provider = context.watch<AccountProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PaliTopBar(title: 'account_management.title'.tr()),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'account_management.linked_bank_account'.tr(),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.disabledFont,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'account_management.one_active_account_msg'.tr(),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.exampleFont,
              ),
            ),
            const SizedBox(height: 24),
            // 계좌 유무에 따른 조건부 렌더링
            provider.hasWallet
                ? _buildAccountSection(context, provider.linkedAccount!)
                : const EmptyWalletCard(),
          ],
        ),
      ),
    );
  }

  // 1. 기존 계좌가 있을 때 보여주는 섹션 (카드 + Replace / Delete)
  Widget _buildAccountSection(BuildContext context, BankAccount account) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.mainBlue,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.mainBlue.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          account.bankName.substring(0, 1),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.mainBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        account.bankName,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                _maskedAccountNumber(account.accountNumber),
                style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'account_management.verified_account'.tr(),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.6),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                  TextButton(
                    onPressed: () => _showDeleteDialog(context),
                    // style: TextButton.styleFrom(
                    //   foregroundColor: Colors.white,
                    // ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Text(
                        'common.delete'.tr(),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // 3. 삭제 확인 다이얼로그
  void _showDeleteDialog(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'account_management.unlink_account'.tr(),
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.abledFont),
        ),
        content: Text(
          'account_management.delete_confirm_msg'.tr(),
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.exampleFont),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'common.cancel'.tr(),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.exampleFont,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // 다이얼로그 닫기

              // PIN 인증 화면으로 이동
              final dynamic pinResult = await Navigator.push<dynamic>(
                parentContext,
                MaterialPageRoute(
                  builder: (_) => const PinScreen(mode: PinMode.auth),
                ),
              );

              bool isAuthenticated =
                  pinResult != null && pinResult.toString().length == 6;

              if (isAuthenticated == true && parentContext.mounted) {
                final String token =
                    parentContext.read<UserProvider>().accessToken ?? "";
                final success = await parentContext
                    .read<AccountProvider>()
                    .unlinkAccount(token);
                if (success && parentContext.mounted) {
                  // 2. 성공 메시지 출력
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        'account_management.delete_success_msg'.tr(),
                      ),
                    ),
                  );

                  // 3. (선택 사항) 삭제 후 홈 화면으로 아예 보내버리고 싶다면?
                  // Navigator.pop(parentContext);
                }
              }
            },
            child: Text(
              'common.delete'.tr(),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.warningRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _maskedAccountNumber(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length <= 4) return raw;

    final visible = digits.substring(digits.length - 4);
    final masked = '•' * (digits.length - 4) + visible;

    final buffer = StringBuffer();
    for (int i = 0; i < masked.length; i++) {
      buffer.write(masked[i]);
      if ((i + 1) % 4 == 0 && i != masked.length - 1) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }
}
