import 'package:flutter/material.dart';
import 'package:palipay_app/core/utils/currency_input_formatter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../account/providers/account_provider.dart';
import '../../wallet/views/wallet_refund_view.dart';
import '../../wallet/views/wallet_topup_view.dart';
import '../../account/views/account_management_view.dart';

class WalletCard extends StatelessWidget {
  final AccountProvider provider;

  const WalletCard({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AccountManagementView()),
      ),
      child: Container(
        width: double.infinity,
        height: 200,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment(-0.8, -1.0),
            end: Alignment(0.8, 1.0),
            colors: [AppColors.warningRed, AppColors.mainBlue],
            stops: [0.2, 0.9],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.mainBlue.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_buildHeader(), _buildBalance(), _buildFooter(context)],
        ),
      ),
    );
  }

  // 내부 컴포넌트들도 작은 메서드로 쪼개면 관리가 더 쉽습니다.
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Main Wallet',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const Icon(Icons.account_balance_wallet, color: Colors.white, size: 18),
      ],
    );
  }

  Widget _buildBalance() {
    // 1. 숫자를 가져와서
    final int amount = provider.linkedAccount?.amount ?? 0;

    // 2. 사전에 정의된 포맷터 양식 적용 (₩ 2,450,000)
    // 만약 CurrencyInputFormatter에 static 메서드가 없다면
    // 아래와 같이 직접 포맷팅하거나 유틸을 호출합니다.
    final String formattedAmount = CurrencyInputFormatter.format(amount);

    return Text(
      '₩ $formattedAmount',
      style: AppTextStyles.titleMedium.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 32,
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CARD HOLDER',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white.withOpacity(0.6),
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'ALEX JOHNSON',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _CardSmallButton(
              label: 'Top-up',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TopupView()),
              ),
            ),
            const SizedBox(width: 8),
            _CardSmallButton(
              label: 'Withdraw',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExchangeView()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// 파일 내부에서만 쓰는 버튼 위젯
class _CardSmallButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CardSmallButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
