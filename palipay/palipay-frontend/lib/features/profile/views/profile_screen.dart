import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:palipay_app/features/user/provider/logout_provider.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../providers/profile_provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../models/profile_user_model.dart';
import '../widgets/language_trailing.dart';
import '../widgets/menu_tile.dart';
import '../widgets/profile_card.dart';
import '../widgets/section_card.dart';
import '../views/change_passowrd_screen.dart';
import '../views/linked_accounts_screen.dart';
import '../../account/views/account_management_view.dart';
import '../../pin/views/pin_screen.dart';
import '../../user/views/login_screen.dart';
import '../../../../core/providers/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   context.read<ProfileProvider>().fetchProfile();
    // });

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

              // 로그인 화면으로 이동 (스택 초기화)
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
                  // 언어 설정 항목을 서비스 섹션 안으로 깔끔하게 이동!
                  MenuTile(
                    icon: Icons.language,
                    title: 'profile.menu_language'.tr(),
                    onTap: () => _showLanguagePicker(context), // 함수 이름 매칭
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // [Account/Security Section]
              SectionCard(
                title: 'profile.section_security'.tr(), // JSON의 'Account' 키 활용
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PinScreen(
                            mode: PinMode.change,
                            walletId: 12345,
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

  // 1. 언어 선택 팝업 함수 (모달 다이얼로그로 변경)
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
            ListTile(
              title: const Text("English", style: AppTextStyles.bodyMedium),
              onTap: () {
                context.setLocale(const Locale('en'));
                Navigator.pop(context); // 선택 후 자동으로 닫기
              },
            ),
            ListTile(
              title: const Text("日本語", style: AppTextStyles.bodyMedium),
              onTap: () {
                context.setLocale(const Locale('ja'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("中文", style: AppTextStyles.bodyMedium),
              onTap: () {
                context.setLocale(const Locale('zh'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 2. 성공 배너 함수 (가독성을 위해 분리)
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
