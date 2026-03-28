import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Theme & Widgets
import 'package:palipay_app/core/theme/app_colors.dart';
import 'package:palipay_app/core/theme/app_text_styles.dart';
import 'package:palipay_app/core/widgets/pali_button.dart';
import 'package:palipay_app/core/widgets/pali_nav_bars.dart';

// Features & Models
import 'package:palipay_app/features/history/models/transaction_model.dart';
import 'package:palipay_app/features/history/providers/history_provider.dart';

// Utils
import 'package:palipay_app/core/utils/date_formatter_util.dart';
import 'package:palipay_app/core/utils/currency_input_formatter.dart';

class HistoryDetailView extends StatelessWidget {
  final Transaction transaction;

  const HistoryDetailView({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final bool isOutput = transaction.category == 'OUTPUT';
    const Color statusColor = AppColors.mainBlue;
    final Color statusBgColor = statusColor.withOpacity(0.08);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PaliTopBar(title: 'history.detail.title'.tr()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 48),

            // 1. 상태 아이콘
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 56,
                  color: statusColor,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 2. 상태 배지
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'history.detail.transaction_successful'.tr(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 3. 금액 및 대상
            Text(
              '${isOutput ? '-' : '+'} ${CurrencyInputFormatter.format(transaction.amount.toInt())} ₩',
              style: AppTextStyles.headlineLarge.copyWith(
                color: AppColors.mainBlue,
                fontWeight: FontWeight.w900,
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${isOutput ? "Sent to" : "Received from"} ${transaction.otherAccountName ?? 'Unknown'}',
              style: AppTextStyles.titleMedium.copyWith(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 32),

            // 4. 영수증 상세 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'history.detail.receipt_details'.tr().toUpperCase(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildReceiptRow(
                    'Transaction Type',
                    isOutput ? 'Withdrawal' : 'Deposit',
                  ),

                  // ✅ 모델에서 .id 게터를 만들었으므로 에러가 사라집니다.
                  _buildReceiptRow(
                    'Transaction ID',
                    'TRX-${transaction.id.toString().padLeft(8, '0')}',
                  ),

                  _buildReceiptRow(
                    'Date',
                    DateFormatterUtil.formatHistoryHeader(
                      context,
                      transaction.createdAt, // ✅ DateTime이므로 그대로 전달
                    ),
                  ),

                  _buildReceiptRow(
                    'Time',
                    DateFormat.jm(
                      context.locale.toString(),
                    ).format(transaction.createdAt), // ✅ DateTime 반영
                  ),

                  // 🚀 환율 정보 표시 (FINANCE_HISTORY_002 연동)
                  FutureBuilder(
                    future: context.read<HistoryProvider>().fetchCurrencyDetail(
                      transaction.id,
                    ), // ✅ id 게터 사용
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: LinearProgressIndicator(minHeight: 2),
                        );
                      }
                      if (snapshot.hasData && snapshot.data != null) {
                        final detail = snapshot.data!;
                        return Column(
                          children: [
                            const Divider(height: 32, color: Color(0xFFF1F5F9)),
                            _buildReceiptRow(
                              '${detail.targetCurrency} Amount',
                              '${detail.targetCurrency == "USD" ? "\$" : ""} ${detail.exchangedAmount.toStringAsFixed(2)}',
                            ),
                            _buildReceiptRow(
                              'Exchange Rate',
                              '1 ${detail.sourceCurrency} = ${detail.exchangeRate}',
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  const Divider(height: 32, color: Color(0xFFF1F5F9)),

                  _buildReceiptRow(
                    'Payment Method',
                    'PaliPay Wallet',
                    icon: Icons.account_balance_wallet_outlined,
                  ),

                  if (transaction.otherBankCode != null)
                    _buildReceiptRow(
                      'Target Bank',
                      'Bank Code: ${transaction.otherBankCode}',
                      icon: Icons.account_balance,
                    ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 5. 하단 홈 버튼
            PaliButton(
              text: 'result.btn_back_to_home'.tr(),
              backgroundColor: AppColors.mainBlue,
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: const Color(0xFF94A3B8),
            ),
          ),
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: AppColors.mainBlue),
                const SizedBox(width: 8),
              ],
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.mainBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
