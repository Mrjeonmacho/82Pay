import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:palipay_app/features/pin/views/pin_screen.dart';
import 'package:palipay_app/features/wallet/views/wallet_result_view.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart'; // PaliTopBar, PaliButton 등
import '../../../core/utils/currency_input_formatter.dart';
import '../providers/wallet_provider.dart';
import '../providers/wallet_provider.dart';
import '../../account/providers/account_provider.dart';
import '../../history/providers/history_provider.dart';
import '../widgets/wallet_account_card.dart';
import '../widgets/quick_amount_row.dart';
import '../widgets/currency_amount_input.dart';

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
    // 진입 시 자동 포커스 (키보드 올리기)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<WalletProvider>();
      final accountProvider = context.read<AccountProvider>();
      final walletId = int.tryParse(accountProvider.linkedAccount?.walletId ?? '0') ?? 0;
      
      provider.initForTopup();
      provider.loadExchangeRateQuote();
      provider.loadWalletBalance(walletId: walletId, amount: 0);
    });
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
                  children: [
                    // ===== 1. 금액 입력 섹션 (위로 이동) =====
                    CurrencyAmountInput(
                      label: 'AMOUNT TO TOP-UP',
                      controller: _controller,
                      focusNode: _focusNode,
                      onChanged: (val) => provider.updateKrwAmountFromText(val),
                    ),
                    const SizedBox(height: 8),

                    // 에러 메시지
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

                    // ===== 2. Transfer Details 표시 (아래로 이동 및 작게) =====
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
                      scale: 0.9, // 카드를 조금 더 작게 표시
                      child: Column(
                        children: [
                          // Source: 외부 계좌
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
                                trailing: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: AppColors.abledFont,
                                ),
                              );
                            },
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Icon(
                              Icons.arrow_downward,
                              color: AppColors.mainBlue,
                            ),
                          ),
                          // Target: 가상 지갑
                          WalletAccountCard(
                            title: '+82Pay Wallet',
                            subtitle: 'Current Balance: ₩ ${CurrencyInputFormatter.format(provider.currentBalance ?? 0)}',
                            icon: Icons.wallet,
                            trailing: const Icon(
                              Icons.check_circle,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildBottomBar(WalletProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
            },
          ),
          const SizedBox(height: 24),
          PaliButton(
            backgroundColor:
                provider.errorMessage == null && provider.krwAmount > 0
                ? AppColors.mainBlue
                : AppColors.disabledBackground,
            text: 'common.add_money'.tr(),
            onPressed: provider.errorMessage == null && provider.krwAmount > 0
                ? () async {
                    // 1. PIN 인증 화면 주석 처리 (나중에 다시 연결)
                    // final String? pinNumber = await Navigator.push<String>(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) =>
                    //         const PinScreen(mode: PinMode.auth),
                    //   ),
                    // );
                    final String? pinNumber = "000000";

                    // 2. 인증 성공 시 충전 로직 실행
                    if (pinNumber != null && mounted) {
                      final accountProvider = context.read<AccountProvider>();
                      final walletId = int.tryParse(accountProvider.linkedAccount?.walletId ?? '0') ?? 0;

                      // 로딩 표시 후 서버 통신
                      final success = await provider.chargeWallet(
                        walletId: walletId,
                        pinNumber: pinNumber,
                      );

                      if (success && mounted) {
                        // 충전 성공 후 AccountProvider 잔액도 함께 갱신 (지갑카드 UI 실시간 반영)
                        final currentBankBalance = accountProvider.linkedAccount?.amount ?? 0;
                        accountProvider.updateBalance(currentBankBalance - provider.krwAmount.toInt());

                        // 거래 내역 바로 반영하기 위해 fetchHistory 호출
                        context.read<HistoryProvider>().fetchHistory(walletId: walletId);

                        // 3. 결과 화면으로 이동 (스택 쌓이지 않게 pushReplacement)
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
                : null,
          ),
        ],
      ),
    );
  }
}
