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
      final provider = context.read<WalletProvider>();
      final accountProvider = context.read<AccountProvider>();

      // AccountProvider에서 통화 정보만 참조
      final currency = accountProvider.linkedAccount?.moneyCode ?? 'USD';

      provider.initForRefund(currency: currency);
      provider.loadExchangeRateQuote();
      provider.loadWalletBalance(amount: 0);

      // 화면 진입 시 키보드 자동 방지
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
                    // ===== 1. 금액 입력 섹션 =====
                    CurrencyAmountInput(
                      controller: _controller,
                      focusNode: _focusNode,
                      onChanged: (val) => provider.updateKrwAmountFromText(val),
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
                              const SnackBar(content: Text('환급 가능한 잔액이 없습니다.')),
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

                    // ===== 2. Transfer Details 표시 =====
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'transfer.details'.tr(),
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
                          // (1) Source: 내 지갑
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
                          // (2) Target: 외부 계좌 (WalletProvider 데이터 연동) 🚀
                          WalletAccountCard(
                            // 🚀 [수정] WalletProvider가 BankConstants에서 찾은 이름을 직접 사용
                            title: provider.bankName,

                            // 🚀 [수정] 지갑 정보에서 가져온 실제 계좌번호 노출
                            subtitle:
                                'WorldBank Account ${provider.maskedAccountNumber}',

                            // 🚀 [수정] 로고가 있으면 로고 이미지를, 없으면 기본 아이콘 표시
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
                // 하단 환급 버튼 onPressed 로직 수정
                onPressed:
                    provider.errorMessage == null &&
                        provider.krwAmount > 0 &&
                        !provider.isLoading
                    ? () async {
                        // 1. PIN 입력 화면 호출 (검증된 PIN 번호를 받아옴)
                        final String? pinNumber = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const PinScreen(mode: PinMode.auth),
                          ),
                        );

                        // 2. PIN 입력이 완료되었고 화면이 여전히 살아있는지 확인
                        if (pinNumber != null && mounted) {
                          // 3. 실제 환급 API 호출
                          final success = await provider.refundWallet(
                            pinNumber: pinNumber,
                          );

                          if (success && mounted) {
                            // 4. 외부 계좌 잔액 업데이트 (입금액 반영)
                            final accountProvider = context
                                .read<AccountProvider>();
                            final currentBankBalance =
                                accountProvider.linkedAccount?.amount ?? 0;

                            accountProvider.updateBalance(
                              currentBankBalance + provider.krwAmount.toInt(),
                            );

                            // 5. 거래 내역 갱신
                            context.read<HistoryProvider>().fetchHistory(
                              walletId: provider.walletId!,
                            );

                            // ✅ 6. [핵심] 결과 화면(WalletResultView)으로 이동
                            // pushAndRemoveUntil을 사용하여 메인 화면(isFirst)만 남기고 이동하면 깔끔합니다.
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WalletResultView(
                                  isRecharge: false, // 환급 모드
                                  amount:
                                      '₩ ${CurrencyInputFormatter.format(provider.krwAmount.toInt())}',
                                ),
                              ),
                              (route) => route.isFirst,
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
