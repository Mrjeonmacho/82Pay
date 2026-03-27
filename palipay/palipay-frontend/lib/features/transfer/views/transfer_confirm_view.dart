import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:palipay_app/features/wallet/providers/wallet_provider.dart';
import 'package:provider/provider.dart';

// Theme & Widgets
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/pali_button.dart';
import '../../../core/widgets/pali_nav_bars.dart';
import '../../../core/utils/currency_input_formatter.dart';

// Features & Providers
import '../../pin/views/pin_screen.dart';
import '../models/transfer_model.dart';
import '../providers/transfer_provider.dart';
import '../../account/providers/account_provider.dart';
import 'transfer_result_view.dart';

class TransferConfirmView extends StatelessWidget {
  final String bankName;
  final String bankCode;
  final String accountNumber;
  final String recipientName;
  final int amount;

  const TransferConfirmView({
    super.key,
    required this.bankName,
    required this.bankCode,
    required this.accountNumber,
    required this.recipientName,
    required this.amount,
  });

  /// 🚀 송금 실행 핸들러
  void _handleSend(BuildContext context) async {
    final transferProvider = context.read<TransferProvider>();
    final walletProvider = context.read<WalletProvider>();

    // 0. 시작 전 에러 메시지 초기화 (이전 에러가 잔상처럼 남지 않게)
    transferProvider.clearError();

    // 1. walletId를 WalletProvider에서 가져오기
    final int walletId = walletProvider.walletId ?? 0;

    if (walletId <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('지갑 정보가 올바르지 않습니다.')));
      return;
    }

    // 2. PIN 인증 화면 호출
    final authenticatedPin = await Navigator.push<String?>(
      context,
      MaterialPageRoute(
        builder: (context) => const PinScreen(mode: PinMode.auth),
      ),
    );

    // 3. 인증 성공 시 송금 프로세스 진행
    if (authenticatedPin != null && context.mounted) {
      final response = await transferProvider.performTransfer(
        TransferRequest(
          walletId: walletId,
          otherBankCode: bankCode,
          otherAccountNumber: accountNumber,
          otherAccountName: recipientName,
          amount: amount.toDouble(),
          accountCurrency: "KRW",
          pinNumber: authenticatedPin,
        ),
      );

      if (!context.mounted) return;

      if (response != null) {
        // ✅ [핵심 추가] 송금 성공 시 WalletProvider 잔액 업데이트
        if (response.currentBalance != null) {
          walletProvider.updateBalanceManually(
            response.currentBalance!.toInt(),
          );
        }

        // ✅ [추가] 성공 화면으로 가기 전 에러 메시지 지우기
        transferProvider.clearError();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TransferResultView(
              recipientName: recipientName,
              amount: amount,
              bankName: bankName,
            ),
          ),
        );
      } else {
        // ❌ 실패 시 스낵바 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              transferProvider.errorMessage ?? 'transfer.error.failed'.tr(),
            ),
            backgroundColor: AppColors.warningRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final transferProvider = context.watch<TransferProvider>();
    final String formattedAmount = CurrencyInputFormatter.format(amount);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: PaliTopBar(title: 'transfer.confirm.title'.tr()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // --- 1. 헤더 영역 ---
              Text(
                'transfer_confirm.send_money'.tr(),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 20,
                  color: AppColors.abledFont,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '₩ $formattedAmount',
                style: AppTextStyles.titleLarge.copyWith(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0D1B63),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'transfer_confirm.to_recipient'.tr(
                  namedArgs: {'name': recipientName},
                ),
                style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 40),

              // --- 2. 이체 정보 카드 ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'transfer_confirm.recipient_details'.tr(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFF0F2F5),
                          child: Icon(
                            Icons.account_balance,
                            color: Color(0xFF0D1B63),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bankName,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              accountNumber,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Divider(thickness: 1, color: Color(0xFFF1F1F1)),
                    const SizedBox(height: 24),

                    _buildConfirmRow(
                      'transfer.confirm.withdraw_from'.tr(),
                      'transfer.confirm.my_wallet'.tr(),
                    ),
                    _buildConfirmRow(
                      'transfer.confirm.transfer_fee'.tr(),
                      'transfer.confirm.free'.tr(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // --- 3. 보안 안내 ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.security, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'transfer_confirm.securely_encrypted'.tr(),
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // --- 4. 하단 버튼 영역 ---
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: PaliButton(
                text: 'common.cancel'.tr(),
                backgroundColor: Colors.white,
                onPressed: () {
                  // ✅ [추가] 취소 시에도 에러 메시지를 지우고 나갑니다.
                  context.read<TransferProvider>().clearError();
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: PaliButton(
                text: transferProvider.isLoading
                    ? 'transfer.confirm.btn_sending'.tr()
                    : 'transfer.confirm.btn_send_now'.tr(),
                backgroundColor: const Color(0xFF0D1B63),
                onPressed: transferProvider.isLoading
                    ? null
                    : () => _handleSend(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
