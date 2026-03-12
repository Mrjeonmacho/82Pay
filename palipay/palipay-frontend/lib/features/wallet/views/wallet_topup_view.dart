import 'package:flutter/material.dart';
import 'package:palipay_app/features/pin/views/pin_screen.dart';
import 'package:palipay_app/features/wallet/views/wallet_result_view.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart'; // PaliTopBar, PaliButton 등
import '../../../core/utils/currency_input_formatter.dart';
import '../providers/wallet_provider.dart';
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
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WalletProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const PaliTopBar(title: 'Top-up'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Source: 외부 계좌
                    const WalletAccountCard(
                      title: 'WELS FARGO',
                      subtitle: 'US Account •••• 1234',
                      icon: Icons.account_balance,
                      trailing: Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.abledFont,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Icon(
                        Icons.arrow_downward,
                        color: AppColors.warningRed,
                      ),
                    ),
                    // Target: 가상 지갑
                    WalletAccountCard(
                      title: '+82Pay Wallet',
                      subtitle:
                          'Current Balance: ₩ ${provider.currentBalance ?? 0}',
                      icon: Icons.wallet,
                      trailing: const Icon(
                        Icons.check_circle,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 60),
                    // 금액 입력 섹션
                    CurrencyAmountInput(
                      label: 'AMOUNT TO TOP-UP',
                      controller: _controller,
                      focusNode: _focusNode,
                      onChanged: (val) => provider.updateKrwAmountFromText(val),
                    ),
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
              _controller.text = CurrencyInputFormatter.format(
                provider.krwAmount.toInt(),
              );
            },
          ),
          const SizedBox(height: 24),
          PaliButton(
            backgroundColor:
                provider.errorMessage == null && provider.krwAmount > 0
                ? AppColors.mainBlue
                : AppColors.disabledBackground,
            text: 'Top-up Now',
            onPressed: provider.errorMessage == null && provider.krwAmount > 0
                ? () async {
                    // 1. PIN 인증 화면 호출 (PinMode.auth)
                    final bool? isAuthenticated = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const PinScreen(mode: PinMode.auth),
                      ),
                    );

                    // 2. 인증 성공 시 충전 로직 실행
                    if (isAuthenticated == true && mounted) {
                      // 로딩 표시 후 서버 통신 (예시)
                      // await context.read<WalletProvider>().recharge();

                      // 3. 결과 화면으로 이동 (스택 쌓이지 않게 pushReplacement)
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WalletResultView(
                            isRecharge: true,
                            amount: '₩ ${provider.krwAmount.toInt()}',
                          ),
                        ),
                      );
                    }
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
