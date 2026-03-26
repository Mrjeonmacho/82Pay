import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:palipay_app/core/utils/currency_input_formatter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../account/providers/account_provider.dart';
import '../../wallet/views/wallet_refund_view.dart';
import '../../wallet/views/wallet_topup_view.dart';
import '../../account/views/account_management_view.dart';

import 'package:provider/provider.dart';
import '../../wallet/providers/wallet_provider.dart';

class WalletCard extends StatefulWidget {
  final AccountProvider provider;

  const WalletCard({super.key, required this.provider});

  @override
  State<WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<WalletCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final walletId =
          int.tryParse(widget.provider.linkedAccount?.walletId ?? '0') ?? 0;
      context.read<WalletProvider>().loadWalletBalance(
        walletId: walletId,
        amount: 0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    context.locale; // 다국어 변경을 감지하여 Rebuild 되도록 의존성 주입
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AccountManagementView()),
      ),
      child: Container(
        width: double.infinity,
        height: 220,
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
          children: [
            _buildHeader(context),
            _buildBalance(context),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  // 내부 컴포넌트들도 작은 메서드로 쪼개면 관리가 더 쉽습니다.
  Widget _buildHeader(BuildContext context) {
    // 헤더는 연동된 계좌(Bank) 정보를 표시
    final String accountName =
        widget.provider.linkedAccount?.accountUsername ?? 'Unknown';
    final String accountNumber =
        widget.provider.linkedAccount?.accountNumber ?? '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'wallet_card.card_holder'.tr(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                accountName.toUpperCase(),
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                _getMaskedAccountNumber(accountNumber),
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
      ],
    );
  }

  String _getMaskedAccountNumber(String number) {
    if (number.isEmpty) return '****';
    // 하이픈 제거 후 마지막 4자리만 추출
    final cleanNum = number.replaceAll('-', '');
    if (cleanNum.length <= 4) return '**** $cleanNum';
    return '**** **** **** ${cleanNum.substring(cleanNum.length - 4)}';
  }

  // 2. 잔액 표시 (중앙 유지)
  Widget _buildBalance(BuildContext context) {
    // 잔액은 지갑(Wallet)의 현재 잔액을 띄워줌
    final walletProvider = context.watch<WalletProvider>();
    final int amount = walletProvider.currentBalance ?? 0;
    final String formattedAmount = CurrencyInputFormatter.format(amount);

    return Text(
      '₩ $formattedAmount',
      style: AppTextStyles.titleMedium.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 34, // 가독성을 위해 폰트 크기 유지 또는 살짝 확대
      ),
    );
  }

  // 3. 푸터: 버튼만 오른쪽으로 정렬
  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end, // 버튼을 오른쪽으로 밀착
      children: [
        _CardSmallButton(
          label: 'common.add_money'.tr(),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TopupView()),
          ),
        ),
        const SizedBox(width: 8),
        _CardSmallButton(
          label: 'common.cash_out'.tr(),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ExchangeView()),
          ),
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
