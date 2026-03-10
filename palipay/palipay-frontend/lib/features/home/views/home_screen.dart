import 'package:flutter/material.dart';
import 'package:palipay_app/features/home/widgets/transactions_section.dart';
import 'package:provider/provider.dart';
import 'package:palipay_app/features/account/providers/account_provider.dart';
import 'package:palipay_app/features/account/views/account_management_view.dart';
import 'package:palipay_app/features/account/views/pin_setting_view.dart'; // 추가됨
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final accountProvider = context.watch<AccountProvider>();
    final bool hasWallet = accountProvider.hasWallet;

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      appBar: const PaliTopBar(title: 'PaliPay'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: hasWallet
                  ? _buildActiveWalletCard(context, accountProvider)
                  : _buildEmptyWalletCard(context),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Recent Transactions',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.abledFont,
                ),
              ),
            ),
            const TransactionsSection(),
          ],
        ),
      ),
      bottomNavigationBar: PaliBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }

  // --- 여기서부터는 build 메서드 밖입니다 ---

  Widget _buildActiveWalletCard(
    BuildContext context,
    AccountProvider provider,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AccountManagementView(),
          ),
        );
      },
      child: PaliBalanceCard(
        krwAmount: '₩ ${provider.linkedAccount?.amount ?? 0}',
      ),
    );
  }

  Widget _buildEmptyWalletCard(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PinSettingView(walletId: '1004'),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.abledFont, // disabledFont에서 abledFont나 상수로 변경 제안
            width: 2,
            style: BorderStyle.solid,
          ),
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
              'Link your bank account',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.abledFont,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
