// lib/features/history/views/history_detail_view.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:palipay_app/core/theme/app_colors.dart';
import 'package:palipay_app/core/theme/app_text_styles.dart';
import 'package:palipay_app/core/widgets/pali_button.dart';
import 'package:palipay_app/core/widgets/pali_nav_bars.dart';
import 'package:palipay_app/features/history/models/transaction_model.dart';
import 'package:palipay_app/features/history/providers/history_provider.dart';
import 'package:provider/provider.dart';

class HistoryDetailView extends StatelessWidget {
  final Transaction transaction;

  const HistoryDetailView({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PaliTopBar(title: 'History Detail'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.check_circle, size: 64, color: Color(0xFF4CAF50)),
            const SizedBox(height: 16),
            Text(
              transaction.otherAccountName ?? 'Merchant',
              style: AppTextStyles.bodySmall,
            ),
            Text(
              '- ${transaction.amount.toInt()} ₩',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),

            // 환산 정보 로드 (FINANCE_HISTORY_002)
            FutureBuilder(
              future: context.read<HistoryProvider>().fetchCurrencyDetail(
                transaction.id,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                final detail = snapshot.data;
                return _buildReceiptTable(detail);
              },
            ),

            const SizedBox(height: 40),
            PaliButton(
              backgroundColor: AppColors.mainBlue,
              text: 'Back to Home',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptTable(TransactionCurrencyDetail? detail) {
    return Column(
      children: [
        _buildReceiptRow(
          'Date of use',
          DateFormat('yyyy-MM-dd HH:mm:ss').format(transaction.createdAt),
        ),
        _buildReceiptRow('Usage Amount', '${transaction.amount.toInt()} ₩'),
        if (detail != null) ...[
          _buildReceiptRow(
            'USD Amount',
            '\$ ${detail.exchangedAmount.toStringAsFixed(2)}',
          ),
          _buildReceiptRow('Exchange Rate', '1 ₩ = ${detail.exchangeRate}'),
        ],
        _buildReceiptRow('Description', transaction.description ?? '-'),
      ],
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
          ),
          Text(value, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
