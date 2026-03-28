import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:palipay_app/features/pin/views/pin_screen.dart';
import 'package:palipay_app/features/wallet/views/wallet_result_view.dart';
import 'package:provider/provider.dart';

// Theme & Widgets
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/utils/currency_input_formatter.dart';

// Providers
import '../../account/providers/account_provider.dart';
import '../../history/providers/history_provider.dart';
import '../providers/wallet_provider.dart';

// Components
import '../widgets/wallet_account_card.dart';
import '../widgets/currency_amount_input.dart';

class ExchangeView extends StatefulWidget {
  const ExchangeView({super.key});

  @override
  State<ExchangeView> createState() => _ExchangeViewState();
}

class _ExchangeViewState extends State<ExchangeView> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final walletProvider = context.read<WalletProvider>();
      final accountProvider = context.read<AccountProvider>();

      final currency = accountProvider.linkedAccount?.moneyCode ?? 'USD';
      final walletId = int.tryParse(accountProvider.walletId ?? '0') ?? 0;

      walletProvider.initWalletData(walletId);
      walletProvider.initForRefund(currency: currency);
      walletProvider.loadExchangeRateQuote();

      // ✅ unfocus 제거 — 키보드가 올라올 수 있도록
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WalletProvider>();

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: PaliTopBar(title: 'common.cash_out'.tr()),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // ===== 1. 금액 입력 섹션 =====
                        CurrencyAmountInput(
                          label: 'AMOUNT TO REFUND',
                          controller: _controller,
                          focusNode: _focusNode,
                          onChanged: (val) =>
                              provider.updateKrwAmountFromText(val),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: _RefundMaxButton(
                            onTap: () {
                              if (provider.currentBalance != null &&
                                  provider.currentBalance! > 0) {
                                final int maxAmount = provider.currentBalance!;
                                provider.updateKrwAmount(maxAmount.toDouble());
                                final String formattedAmount =
                                    CurrencyInputFormatter.format(maxAmount);
                                _controller.value = TextEditingValue(
                                  text: formattedAmount,
                                  selection: TextSelection.collapsed(
                                    offset: formattedAmount.length,
                                  ),
                                );
                                _focusNode.unfocus();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('환급 가능한 잔액이 없습니다.'),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 8),

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

                        const SizedBox(height: 48),

                        // ===== 2. Transfer Details =====
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'TRANSFER DETAILS',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.abledFont,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Transform.scale(
                          scale: 0.9,
                          child: Column(
                            children: [
                              WalletAccountCard(
                                title: '+82Pay Wallet',
                                subtitle:
                                    'Balance: ₩ ${CurrencyInputFormatter.format(provider.currentBalance ?? 0)}',
                                iconWidget: const Icon(
                                  Icons.wallet,
                                  color: AppColors.mainBlue,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Icon(
                                  Icons.arrow_downward,
                                  color: AppColors.mainBlue,
                                ),
                              ),
                              WalletAccountCard(
                                title: provider.bankName,
                                subtitle:
                                    'WorldBank Account ${provider.maskedAccountNumber}',
                                iconWidget: provider.bankLogo != null
                                    ? Image.asset(
                                        provider.bankLogo!,
                                        width: 32,
                                        height: 32,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.account_balance,
                                                  size: 32,
                                                  color: AppColors.abledFont,
                                                ),
                                      )
                                    : const Icon(
                                        Icons.account_balance,
                                        size: 32,
                                        color: AppColors.abledFont,
                                      ),
                              ),
                            ],
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
                    backgroundColor:
                        provider.errorMessage == null && provider.krwAmount > 0
                        ? AppColors.mainBlue
                        : AppColors.disabledBackground,
                    text: 'common.cash_out'.tr(),
                    onPressed:
                        provider.errorMessage == null &&
                            provider.krwAmount > 0 &&
                            !provider.isLoading
                        ? () async {
                            final int pinWalletId =
                                int.tryParse(
                                  context.read<AccountProvider>().walletId ??
                                      '0',
                                ) ??
                                0;

                            final String? pinNumber =
                                await Navigator.push<String>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PinScreen(
                                      mode: PinMode.auth,
                                      walletId: pinWalletId,
                                    ),
                                  ),
                                );

                            if (pinNumber != null && mounted) {
                              final success = await provider.refundWallet(
                                pinNumber: pinNumber,
                              );

                              if (success && mounted) {
                                final accountProvider = context
                                    .read<AccountProvider>();
                                final currentBankBalance =
                                    accountProvider.linkedAccount?.amount ?? 0;
                                accountProvider.updateBalance(
                                  currentBankBalance +
                                      provider.krwAmount.toInt(),
                                );

                                final historyWalletId = provider.walletId;
                                if (historyWalletId != null) {
                                  context.read<HistoryProvider>().fetchHistory(
                                    walletId: historyWalletId,
                                  );
                                }

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WalletResultView(
                                      isRecharge: false,
                                      amount:
                                          '₩ ${CurrencyInputFormatter.format(provider.krwAmount.toInt())}',
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ✅ 로딩 오버레이 — isLoading일 때 화면 중앙에 표시
        if (provider.isLoading)
          const Positioned.fill(
            child: AbsorbPointer(
              child: ColoredBox(
                color: Colors.black12,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.mainBlue,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _RefundMaxButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RefundMaxButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          // ✅ 버튼처럼 확실히 보이도록 배경색 변경
          color: AppColors.mainBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.mainBlue, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.north, size: 12, color: AppColors.mainBlue),
            const SizedBox(width: 4),
            Text(
              'wallet.refund.max'.tr(),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.mainBlue,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
