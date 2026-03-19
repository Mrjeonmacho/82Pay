import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
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

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = dummyProfileUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: PaliTopBar(
        title: 'Profile',
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.mainBlue),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileCard(name: user.name, email: user.email),
              const SizedBox(height: 24),

              SectionCard(
                title: 'Service',
                children: [
                  MenuTile(
                    icon: Icons.account_balance_outlined,
                    title: 'Linked Accounts',
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
                    title: 'Language',
                    trailing: LanguageTrailing(language: user.language),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              SectionCard(
                title: 'Account',
                children: [
                  MenuTile(
                    icon: Icons.key_outlined,
                    title: 'Change Password',
                    onTap: () async {
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChangePasswordScreen(),
                        ),
                      );

                      if (result == true && context.mounted) {
                        final messenger = ScaffoldMessenger.of(context);

                        messenger
                          ..hideCurrentMaterialBanner()
                          ..showMaterialBanner(
                            MaterialBanner(
                              backgroundColor: AppColors.mainBlue,
                              content: const Text(
                                'Your password has been changed successfully.',
                                style: TextStyle(color: Colors.white),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    messenger.hideCurrentMaterialBanner();
                                  },
                                  child: const Text(
                                    'OK',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  MenuTile(
                    icon: Icons.lock_outline,
                    title: 'Change PIN',
                    onTap: () async {
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PinScreen(
                            mode: PinMode.change,
                            walletId: 12345, // TODO: 나중에 실제 walletId로 교체
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  const MenuTile(
                    icon: Icons.no_accounts,
                    title: 'Delete Account',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
