import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:palipay_app/features/pin/views/pin_screen.dart';
import 'package:palipay_app/features/wallet/views/wallet_result_view.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/utils/currency_input_formatter.dart';
import '../../account/providers/account_provider.dart';
import '../../history/providers/history_provider.dart';
import '../../account/providers/account_provider.dart';
import '../../history/providers/history_provider.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<WalletProvider>();
      final accountProvider = context.read<AccountProvider>();
      final walletId = int.tryParse(accountProvider.linkedAccount?.walletId ?? '0') ?? 0;
      final currency = accountProvider.linkedAccount?.moneyCode ?? 'USD';
      
      provider.initForRefund(currency: currency);
      provider.loadExchangeRateQuote();
      provider.loadWalletBalance(walletId: walletId, amount: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WalletProvider>();

    return Scaffold(
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
                    // ===== 1. 금액 입력 섹션 (위로 이동) =====
                    CurrencyAmountInput(
                      label: 'AMOUNT TO REFUND',
                      controller: _controller,
                      onChanged: (val) => provider.updateKrwAmountFromText(val),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _RefundMaxButton(
                        onTap: () async {
                          // 우선 로딩을 방지하기 위해 Provider에서 최신 잔액을 가져오는 API 호출
                          final accountProvider = context.read<AccountProvider>();
                          final walletId = int.tryParse(accountProvider.linkedAccount?.walletId ?? '0') ?? 0;
                          
                          await provider.loadMaxRefundable(walletId);
                          
                          // 받아온 최대 환급 가능 금액 적용
                          final maxAmount = provider.maxRefundableAmount ?? 0;
                          provider.updateKrwAmount(maxAmount.toDouble());
                          final newText = CurrencyInputFormatter.format(maxAmount);
                          _controller.value = TextEditingValue(
                            text: newText,
                            selection: TextSelection.collapsed(offset: newText.length),
                          );
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

                    // ===== 2. Transfer Details 표시 (아래로 뺌) =====
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
                          // Source: 가상 지갑
                          WalletAccountCard(
                            title: '+82Pay Wallet',
                            subtitle: 'Balance: ₩ ${CurrencyInputFormatter.format(provider.currentBalance ?? 0)}',
                            icon: Icons.wallet,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Icon(
                              Icons.arrow_downward,
                              color: AppColors.mainBlue,
                            ),
                          ),
                          // Target: 외부 계좌 (AccountProvider 연동)
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
                    provider.errorMessage == null && provider.krwAmount > 0
                    ? () async {
                        // PIN 인증 스킵 (나중에 활성화)
                        // final String? pinNumber =
                        //     await Navigator.push<String>(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) =>
                        //             const PinScreen(mode: PinMode.auth),
                        //       ),
                        //     );
                        final String? pinNumber = "000000";

                        // 2. 인증 성공 시 환급 로직 실행
                        if (pinNumber != null && mounted) {
                          final accountProvider = context.read<AccountProvider>();
                          final walletId = int.tryParse(accountProvider.linkedAccount?.walletId ?? '0') ?? 0;

                          // 서버 통신
                          final success = await provider.refundWallet(
                            walletId: walletId,
                            pinNumber: pinNumber,
                          );

                          if (success && mounted) {
                            // 성공 시 UI 실시간 잔액 반영
                            final currentBankBalance = accountProvider.linkedAccount?.amount ?? 0;
                            accountProvider.updateBalance(currentBankBalance + provider.krwAmount.toInt());

                            // 거래 내역 바로 반영하기 위해 fetchHistory 호출
                            context.read<HistoryProvider>().fetchHistory(walletId: walletId);

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WalletResultView(
                                  isRecharge: false,
                                  amount: '₩ ${CurrencyInputFormatter.format(provider.krwAmount.toInt())}',
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
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Text(
          'wallet.refund.max'.tr(),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.mainBlue,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
