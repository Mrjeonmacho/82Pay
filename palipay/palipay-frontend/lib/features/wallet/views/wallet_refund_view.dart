import 'package:flutter/material.dart';
import 'package:palipay_app/features/pin/views/pin_screen.dart';
import 'package:palipay_app/features/wallet/views/wallet_result_view.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../providers/wallet_provider.dart';
import '../widgets/wallet_account_card.dart';
import '../widgets/currency_amount_input.dart';

class ExchangeView extends StatefulWidget {
  const ExchangeView({super.key});

  @override
  State<ExchangeView> createState() => _ExchangeViewState();
}

class _ExchangeViewState extends State<ExchangeView> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WalletProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const PaliTopBar(title: 'Refund'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Source: 가상 지갑 (이번엔 지갑이 먼저!)
                    WalletAccountCard(
                      title: '+82Pay Wallet',
                      subtitle: 'Balance: ₩ ${provider.currentBalance ?? 0}',
                      icon: Icons.wallet,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Icon(
                        Icons.arrow_downward,
                        color: AppColors.mainBlue,
                      ),
                    ),
                    // Target: 외부 계좌
                    const WalletAccountCard(
                      title: 'WELS FARGO',
                      subtitle: 'US Account •••• 1234',
                      icon: Icons.account_balance,
                      trailing: Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.abledFont,
                      ),
                    ),
                    const SizedBox(height: 60),
                    // 금액 입력 섹션
                    CurrencyAmountInput(
                      label: 'AMOUNT TO REFUND',
                      controller: _controller,
                      onChanged: (val) => provider.updateKrwAmountFromText(val),
                    ),
                    if (provider.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          provider.errorMessage!,
                          style: const TextStyle(
                            color: AppColors.warningRed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // 하단 환급 버튼
            Padding(
              padding: const EdgeInsets.all(24),
              child: PaliButton(
                backgroundColor: AppColors.mainBlue,
                text: 'Refund Now',
                onPressed:
                    provider.errorMessage == null && provider.krwAmount > 0
                    ? () async {
                        final bool? isAuthenticated =
                            await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PinScreen(mode: PinMode.auth),
                              ),
                            );
                        // 2. 인증 성공 시 환급 로직 실행
                        if (isAuthenticated == true && mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WalletResultView(
                                isRecharge: false,
                                // 기획서 3번 반영: 외화 기준으로 환불 금액 표시
                                amount:
                                    '\$ ${provider.foreignAmount.toStringAsFixed(2)}',
                              ),
                            ),
                          );
                        }
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
