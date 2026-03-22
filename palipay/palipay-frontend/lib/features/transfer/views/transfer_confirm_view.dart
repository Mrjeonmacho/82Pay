// lib/features/transfer/views/transfer_confirm_view.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/pali_button.dart';
import '../../../core/widgets/pali_nav_bars.dart';
import '../../../core/utils/currency_input_formatter.dart'; // 공통 유틸 활용
import '../../pin/views/pin_screen.dart';
import '../models/transfer_model.dart';
import '../providers/transfer_provider.dart';
import 'transfer_result_view.dart';

class TransferConfirmView extends StatelessWidget {
  final String bankName;
  final String accountNumber;
  final String recipientName;
  final int amount;

  const TransferConfirmView({
    super.key,
    required this.bankName,
    required this.accountNumber,
    required this.recipientName,
    required this.amount,
  });

  void _handleSend(BuildContext context) async {
    final authenticated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const PinScreen(mode: PinMode.auth),
      ),
    );

    if (authenticated == true && context.mounted) {
      final provider = context.read<TransferProvider>();

      final success = await provider.sendMoney(
        TransferRequest(
          toBank: bankName,
          toAccount: accountNumber,
          toName: recipientName,
          amount: amount,
        ),
      );

      if (success && context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TransferResultView(
              recipientName: recipientName,
              amount: amount,
            ),
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
      // 결과 페이지와 통일된 배경색
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: PaliTopBar(
        title: 'transfer.confirm.title'.tr(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // 1. 헤더 영역: 질문 뉘앙스
              Text(
                'transfer_confirm.send_money'.tr(),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 32,
                  color: AppColors.disabledFont,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'transfer_confirm.amount_krw'.tr(namedArgs: {'amount': formattedAmount}),
                style: AppTextStyles.titleLarge.copyWith(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0D1B63), // 결과창과 동일한 네이비
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'transfer_confirm.to_recipient'.tr(namedArgs: {'name': recipientName}),
                style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 48),

              // 2. 이체 정보 카드 (결과창 영수증과 통일)
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
                    
                    // 수취 은행 및 계좌
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFF0F2F5),
                          child: Icon(Icons.account_balance, color: Color(0xFF0D1B63), size: 20),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(bankName,
                                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(accountNumber,
                                style: AppTextStyles.bodySmall.copyWith(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    const Divider(thickness: 1, color: Color(0xFFF1F1F1)),
                    const SizedBox(height: 24),

                    // 추가 정보 (출금 계좌 등)
                    _buildConfirmRow('transfer.confirm.withdraw_from'.tr(), 'transfer.confirm.my_wallet'.tr()),
                    _buildConfirmRow('transfer.confirm.transfer_fee'.tr(), 'transfer.confirm.free'.tr()),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 보안 안내 문구 (심리적 안정감)
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
      
      // 3. 하단 버튼 영역
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40), // 하단 여백 확보
        child: Row(
          children: [
            // 취소 버튼 (보조 버튼)
            Expanded(
              flex: 1,
              child: PaliButton(
                text: 'common.cancel'.tr(),
                backgroundColor: Colors.white,
                // 테두리가 있는 스타일을 원하시면 PaliButton 내부에서 처리하거나 
                // 아래처럼 스타일을 조정하세요.
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 12),
            // 송금 버튼 (주요 버튼)
            Expanded(
              flex: 2, // 송금 버튼을 더 넓게 배치하여 강조
              child: PaliButton(
                text: transferProvider.isLoading ? 'transfer.confirm.btn_sending'.tr() : 'transfer.confirm.btn_send_now'.tr(),
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

  // 정보 한 줄을 그리는 보조 위젯
  Widget _buildConfirmRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey)),
          Text(value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              )),
        ],
      ),
    );
  }
}