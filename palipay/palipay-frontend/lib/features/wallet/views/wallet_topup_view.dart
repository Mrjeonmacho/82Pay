import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

// Theme & Widgets
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/utils/currency_input_formatter.dart';

// Providers
import '../providers/wallet_provider.dart';
import '../../account/providers/account_provider.dart';
import '../../history/providers/history_provider.dart';

// Features & Components
import '../widgets/wallet_account_card.dart';
import '../widgets/quick_amount_row.dart';
import '../widgets/currency_amount_input.dart';
import '../../wallet/views/wallet_result_view.dart';
import '../../pin/views/pin_screen.dart';

class TopupView extends StatefulWidget {
  const TopupView({super.key});

  @override
  State<TopupView> createState() => _TopupViewState();
}

class _TopupViewState extends State<TopupView> {
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
      walletProvider.initForTopup(currency: currency);
      walletProvider.loadExchangeRateQuote();

      // 충전 화면은 퀵 버튼 방식이라 진입 시 키보드 자동 방지 유지
      _focusNode.unfocus();
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
          appBar: PaliTopBar(title: 'common.add_money'.tr()),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. 금액 입력 섹션
                        CurrencyAmountInput(
                          label: 'AMOUNT TO TOP-UP',
                          controller: _controller,
                          focusNode: _focusNode,
                          onChanged: (val) =>
                              provider.updateKrwAmountFromText(val),
                        ),
                        const SizedBox(height: 8),

                        if (provider.errorMessage != null)
                          Text(
                            provider.errorMessage!,
                            style: const TextStyle(
                              color: AppColors.warningRed,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                        const SizedBox(height: 48),

                        // 2. Transfer Details 섹션
                        Text(
                          'TRANSFER DETAILS',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.abledFont,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Transform.scale(
                          scale: 0.9,
                          alignment: Alignment.topCenter,
                          child: _buildTransferCards(provider),
                        ),
                      ],
                    ),
                  ),
                ),

                // 하단 액션 바
                _buildBottomBar(provider),
              ],
            ),
          ),
        ),

        // ✅ 로딩 오버레이
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

  Widget _buildTransferCards(WalletProvider provider) {
    return Column(
      children: [
        Consumer<AccountProvider>(
          builder: (context, accProvider, child) {
            final account = accProvider.linkedAccount;
            final String accNum = account?.accountNumber ?? '••••';
            final String maskedAcc = accNum.length > 4
                ? '•••• ${accNum.substring(accNum.length - 4)}'
                : accNum;

            return WalletAccountCard(
              title: provider.bankName,
              subtitle: 'WorldBank Account $maskedAcc',
              iconWidget: provider.bankLogo != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        provider.bankLogo!,
                        width: 30,
                        height: 30,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.account_balance,
                              color: AppColors.mainBlue,
                            ),
                      ),
                    )
                  : const Icon(
                      Icons.account_balance,
                      color: AppColors.mainBlue,
                    ),
            );
          },
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Icon(Icons.arrow_downward, color: AppColors.mainBlue),
        ),
        WalletAccountCard(
          title: '+82Pay Wallet',
          subtitle:
              'Current Balance: ₩ ${CurrencyInputFormatter.format(provider.currentBalance ?? 0)}',
          iconWidget: const Icon(Icons.wallet, color: AppColors.abledFont),
        ),
      ],
    );
  }

  Widget _buildBottomBar(WalletProvider provider) {
    final bool canSubmit =
        provider.errorMessage == null && provider.krwAmount > 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          QuickAmountRow(
            onAmountSelected: (amt) {
              provider.addQuickAmount(amt);
              final newText = CurrencyInputFormatter.format(
                provider.krwAmount.toInt(),
              );
              _controller.value = TextEditingValue(
                text: newText,
                selection: TextSelection.collapsed(offset: newText.length),
              );
              _focusNode.unfocus();
            },
          ),
          const SizedBox(height: 24),
          PaliButton(
            backgroundColor: canSubmit
                ? AppColors.mainBlue
                : AppColors.disabledBackground,
            text: 'common.add_money'.tr(),
            onPressed: canSubmit && !provider.isLoading
                ? () => _handleTopup(provider)
                : null,
          ),
        ],
      ),
    );
  }

  Future<void> _handleTopup(WalletProvider provider) async {
    final int pinWalletId =
        int.tryParse(context.read<AccountProvider>().walletId ?? '0') ?? 0;

    final String? pinNumber = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PinScreen(mode: PinMode.auth, walletId: pinWalletId),
      ),
    );

    if (pinNumber != null && mounted) {
      final success = await provider.chargeWallet(pinNumber: pinNumber);

      if (success && mounted) {
        final accountProvider = context.read<AccountProvider>();
        final currentBankBalance = accountProvider.linkedAccount?.amount ?? 0;
        accountProvider.updateBalance(
          currentBankBalance - provider.krwAmount.toInt(),
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
              isRecharge: true,
              amount:
                  '₩ ${CurrencyInputFormatter.format(provider.krwAmount.toInt())}',
            ),
          ),
          (route) => route.isFirst, // 메인 화면(첫 화면)만 남기고 모두 제거
        );
      }
    }
  }
}
