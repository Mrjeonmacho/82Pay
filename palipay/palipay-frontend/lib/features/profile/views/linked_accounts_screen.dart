import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/widgets/pali_bank_selection_sheet.dart';
import '../../account/providers/account_provider.dart';
import 'package:palipay_app/core/providers/user_provider.dart';

import 'unlink_pin_auth_screen.dart';

class LinkedAccountsView extends StatefulWidget {
  const LinkedAccountsView({super.key});

  @override
  State<LinkedAccountsView> createState() => _LinkedAccountsViewState();
}

class _LinkedAccountsViewState extends State<LinkedAccountsView> {
  Future<void> _handleDelete() async {
    // 1. PIN 인증 화면 호출
    final pinResult = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const UnlinkPinAuthView()),
    );

    if (pinResult != true || !mounted) return;

    // 🚀 [accessToken 선언 및 할당]
    // UserProvider에서 저장된 토큰을 가져옵니다.
    final userProvider = context.read<UserProvider>();
    final String? accessToken = userProvider.accesstoken;

    // 2. 토큰 유효성 검사
    if (accessToken == null || accessToken.isEmpty) {
      debugPrint("🚨 [LinkedAccounts] AccessToken이 비어있습니다.");
      _showCenterMessage('토큰이 없습니다. 다시 로그인해주세요.');
      return;
    }

    // 3. 계좌 해지 API 호출
    final success = await context.read<AccountProvider>().unlinkAccount(
      accessToken,
    );

    if (!mounted) return;

    if (success) {
      _showCenterMessage('profile.linked.msg_removed'.tr());
    } else {
      _showCenterMessage('profile.linked.msg_failed'.tr());
    }
  }

  void _showCenterMessage(String message) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'message',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });

        return SafeArea(
          child: Stack(
            children: [
              Positioned(
                left: 24,
                right: 24,
                top: MediaQuery.of(context).size.height * 0.37,
                child: Material(
                  color: AppColors.mainBlue,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mainBlue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.buttonFont,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AccountProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PaliTopBar(title: 'profile.linked.title'.tr()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: provider.hasWallet
              ? _LinkedAccountCard(
                  accountNumber:
                      provider.linkedAccount?.accountNumber ?? '000-0000-0000',
                  onDelete: _handleDelete,
                )
              : const _EmptyLinkedAccountCard(),
        ),
      ),
    );
  }
}

class _LinkedAccountCard extends StatelessWidget {
  final String accountNumber;
  final VoidCallback onDelete;

  const _LinkedAccountCard({
    required this.accountNumber,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 170,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [AppColors.warningRed, AppColors.mainBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 6,
            left: 0,
            child: Text(
              'profile.linked.my_account'.tr(),
              style: AppTextStyles.headlineLarge.copyWith(
                color: AppColors.buttonFont,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 22,
            child: Text(
              accountNumber,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.buttonFont,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: AppColors.mainBlue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyLinkedAccountCard extends StatelessWidget {
  const _EmptyLinkedAccountCard();

  void _handleLink(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    final countryCode = userProvider.countryCode ?? 'US';

    _openBankSelection(context, countryCode);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _handleLink(context),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        height: 170,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.abledFont, width: 2),
        ),
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
    );
  }

  // 은행 선택 바텀시트
  void _openBankSelection(BuildContext context, String userCountry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => BankSelectionSheet(
        countryCode: userCountry, // 'US'면 미국, 'KR'이면 한국
        onSelect: (selectedBank) {
          // 선택된 정보로 다음 화면 이동 또는 상태 업데이트
          print(
            "선택된 은행: ${selectedBank['name']}, 코드: ${selectedBank['bankCode']}",
          );
        },
      ),
    );
  }
}
