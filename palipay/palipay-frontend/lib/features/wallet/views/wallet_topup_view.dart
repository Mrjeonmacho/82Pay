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
      
      final linkedAccount = accountProvider.linkedAccount;
      final walletId = int.tryParse(linkedAccount?.walletId ?? '0') ?? 0;
      final currency = linkedAccount?.moneyCode ?? 'USD';

      walletProvider.initForTopup(currency: currency);
      walletProvider.loadExchangeRateQuote();
      walletProvider.loadWalletBalance(walletId: walletId, amount: 0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WalletProvider>();

    return Scaffold(
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
                      // focusNode: _focusNode,
                      onChanged: (val) => provider.updateKrwAmountFromText(val),
                    ),
                    const SizedBox(height: 8),

                    // 에러 메시지
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
    );
  }

  // 송금 정보 카드 위젯 분리
  Widget _buildTransferCards(WalletProvider provider) {
    return Column(
      children: [
        Consumer<AccountProvider>(
          builder: (context, accProvider, child) {
            final account = accProvider.linkedAccount;
            final String bankName = account?.bankName ?? 'Unknown Bank';
            final String accNum = account?.accountNumber ?? '••••';
            final String maskedAcc = accNum.length > 4
                ? '•••• ${accNum.substring(accNum.length - 4)}'
                : accNum;

            return WalletAccountCard(
              title: bankName,
              subtitle: '${account?.moneyCode ?? "Local"} Account $maskedAcc',
              icon: Icons.account_balance,
              trailing: const Icon(Icons.keyboard_arrow_down, color: AppColors.abledFont),
            );
          },
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Icon(Icons.arrow_downward, color: AppColors.mainBlue),
        ),
        WalletAccountCard(
          title: '+82Pay Wallet',
          subtitle: 'Current Balance: ₩ ${CurrencyInputFormatter.format(provider.currentBalance ?? 0)}',
          icon: Icons.wallet,
          trailing: const Icon(Icons.check_circle, color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }

  Widget _buildBottomBar(WalletProvider provider) {
    final bool canSubmit = provider.errorMessage == null && provider.krwAmount > 0;

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
              final newText = CurrencyInputFormatter.format(provider.krwAmount.toInt());
              _controller.value = TextEditingValue(
                text: newText,
                selection: TextSelection.collapsed(offset: newText.length),
              );
            },
          ),
          const SizedBox(height: 24),
          PaliButton(
            backgroundColor: canSubmit ? AppColors.mainBlue : AppColors.disabledBackground,
            text: 'common.add_money'.tr(),
            onPressed: canSubmit ? () => _handleTopup(provider) : null,
          ),
        ],
      ),
    );
  }

  Future<void> _handleTopup(WalletProvider provider) async {
    // PIN 인증 로직 (현재 테스트용 하드코딩)
    const String? pinNumber = "000000";

    if (pinNumber != null && mounted) {
      final accountProvider = context.read<AccountProvider>();
      final walletId = int.tryParse(accountProvider.linkedAccount?.walletId ?? '0') ?? 0;

      // 1. 충전 요청
      final success = await provider.chargeWallet(
        walletId: walletId,
        pinNumber: pinNumber,
      );

      if (success && mounted) {
        // 2. 잔액 및 히스토리 갱신
        final currentBankBalance = accountProvider.linkedAccount?.amount ?? 0;
        accountProvider.updateBalance(currentBankBalance - provider.krwAmount.toInt());
        context.read<HistoryProvider>().fetchHistory(walletId: walletId);

        // 3. 결과 화면 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WalletResultView(
              isRecharge: true,
              amount: '₩ ${CurrencyInputFormatter.format(provider.krwAmount.toInt())}',
            ),
          ),
        );
      }
    }
  }
}