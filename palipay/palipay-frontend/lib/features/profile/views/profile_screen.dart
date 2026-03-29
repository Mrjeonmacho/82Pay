import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:palipay_app/features/user/provider/logout_provider.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../widgets/menu_tile.dart';
import '../widgets/profile_card.dart';
import '../widgets/section_card.dart';
import '../views/change_passowrd_screen.dart';
import '../../account/views/account_management_view.dart';
import '../../pin/views/pin_screen.dart';
import '../../user/views/login_screen.dart';
import '../../../../core/providers/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. UserProvider를 감시하여 실시간으로 데이터(walletId 등)를 가져옵니다.
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: PaliTopBar(
        title: 'profile.title'.tr(),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.mainBlue),
            onPressed: () async {
              await context.read<LogoutProvider>().logout(context);

              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ProfileCard(),
              const SizedBox(height: 24),

              // [Service Section]
              SectionCard(
                title: 'profile.section_service'.tr(),
                children: [
                  MenuTile(
                    icon: Icons.account_balance_outlined,
                    title: 'profile.menu_linked_accounts'.tr(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AccountManagementView(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  MenuTile(
                    icon: Icons.language,
                    title: 'profile.menu_language'.tr(),
                    onTap: () => _showLanguagePicker(context),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // [Account/Security Section]
              SectionCard(
                title: 'profile.section_security'.tr(),
                children: [
                  MenuTile(
                    icon: Icons.key_outlined,
                    title: 'profile.menu_change_password'.tr(),
                    onTap: () async {
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChangePasswordScreen(),
                        ),
                      );
                      if (result == true && context.mounted) {
                        _showSuccessBanner(context);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  MenuTile(
                    icon: Icons.lock_outline,
                    title: 'profile.menu_change_pin'.tr(),
                    onTap: () {
                      // 🚀 [핵심 수정] 하드코딩을 제거하고 실제 walletId를 파싱하여 넘깁니다.
                      final String? rawWalletId = userProvider.walletId;
                      final int? actualWalletId = rawWalletId != null
                          ? int.tryParse(rawWalletId)
                          : null;

                      if (actualWalletId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Wallet information is not available.',
                            ),
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PinScreen(
                            mode: PinMode.change,
                            walletId: actualWalletId, // 실제 ID 전달
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // 언어 선택 팝업 함수
  void _showLanguagePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'profile.menu_language'.tr(),
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        contentPadding: const EdgeInsets.only(top: 16, bottom: 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _languageOption(context, "English", 'en'),
            _languageOption(context, "日本語", 'ja'),
            _languageOption(context, "中文", 'zh'),
            _languageOption(context, "한국어", 'ko'),
          ],
        ),
      ),
    );
  }

  Widget _languageOption(BuildContext context, String label, String langCode) {
    return ListTile(
      title: Text(label, style: AppTextStyles.bodyMedium),
      onTap: () {
        context.setLocale(Locale(langCode));
        Navigator.pop(context);
      },
    );
  }

  // 성공 배너 함수
  void _showSuccessBanner(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(
        MaterialBanner(
          backgroundColor: AppColors.mainBlue,
          content: Text(
            'profile.msg_password_changed'.tr(),
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => messenger.hideCurrentMaterialBanner(),
              child: Text(
                'common.ok'.tr(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
  }
}
