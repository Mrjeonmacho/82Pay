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
import '../../pin/views/pin_screen.dart'; // 💡 PIN 화면 임포트

class TopupView extends StatefulWidget {
  const TopupView({super.key});

  @override
  State<TopupView> createState() => _TopupViewState();
}

class _TopupViewState extends State<TopupView> {
  final TextEditingController _controller = TextEditingController();
  // 💡 커서 깜빡임(자동 키보드) 방지를 위한 FocusNode
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final walletProvider = context.read<WalletProvider>();
      final accountProvider = context.read<AccountProvider>();

      final currency = accountProvider.linkedAccount?.moneyCode ?? 'USD';
      final walletId = int.parse(accountProvider.walletId ?? '0');

      // walletId 주입 + 지갑 정보 로드를 단일 진입점으로 처리
      walletProvider.initWalletData(walletId);
      walletProvider.initForTopup(currency: currency);
      walletProvider.loadExchangeRateQuote();

      _focusNode.unfocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose(); // FocusNode 해제
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
                      // 💡 FocusNode를 연결하여 커서 자동 깜빡임 제어
                      focusNode: _focusNode,
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
              // 💡 퀵 버튼 클릭 시에는 키보드를 올리지 않도록 포커스 해제
              _focusNode.unfocus();
            },
          ),
          const SizedBox(height: 24),
          PaliButton(
            backgroundColor: canSubmit
                ? AppColors.mainBlue
                : AppColors.disabledBackground,
            text: 'common.add_money'.tr(),
            // 로딩 중일 때는 버튼 비활성화 (중복 클릭 방지)
            onPressed: canSubmit && !provider.isLoading
                ? () => _handleTopup(provider)
                : null,
          ),
        ],
      ),
    );
  }

  Future<void> _handleTopup(WalletProvider provider) async {
    final String? pinNumber = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const PinScreen(mode: PinMode.auth),
      ),
    );

    if (pinNumber != null && mounted) {
      final success = await provider.chargeWallet(pinNumber: pinNumber);

      if (success && mounted) {
        final accountProvider = context.read<AccountProvider>();

        // 외부 은행 계좌 잔액 차감
        final currentBankBalance = accountProvider.linkedAccount?.amount ?? 0;
        accountProvider.updateBalance(
          currentBankBalance - provider.krwAmount.toInt(),
        );

        // 히스토리 갱신 — walletId null 안전 처리
        final walletId = provider.walletId;
        if (walletId != null) {
          context.read<HistoryProvider>().fetchHistory(walletId: walletId);
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
        );
      }
    }
  }
}
