import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers & Models
import 'package:palipay_app/features/history/providers/history_provider.dart';
import 'package:palipay_app/features/wallet/providers/wallet_provider.dart';
import 'package:palipay_app/features/history/models/transaction_model.dart';

// Views
import 'package:palipay_app/features/history/views/history_view.dart';

// Core Utils & Theme
import '../../../core/utils/currency_input_formatter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class TransactionsSection extends StatefulWidget {
  const TransactionsSection({super.key});

  @override
  State<TransactionsSection> createState() => _TransactionsSectionState();
}

class _TransactionsSectionState extends State<TransactionsSection> {
  @override
  Widget build(BuildContext context) {
    final historyProvider = context.watch<HistoryProvider>();

    // [방어 코드] 진입 시 walletId가 null이었다가 뒤늦게 들어온 경우 처리
    if (!_isInitialFetched &&
        walletProvider.walletId != null &&
        walletProvider.walletId! > 0) {
      Future.microtask(() => _loadHistoryInitially());
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: Column(
        children: [_buildHeader(context), _buildList(historyProvider)],
      ),
    );
  }

  // --- 1. 헤더 영역 ---
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'home_screen.recent_transactions'.tr(),
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: const Color(0xFF2E3A59),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryView()),
            ),
            child: _buildGlassButton('common.see_all'.tr().toUpperCase()),
          ),
        ],
      ),
    );
  }

  // --- 2. 거래 내역 리스트 ---
  Widget _buildList(HistoryProvider provider) {
    if (provider.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.mainBlue),
        ),
      );
    }

    final items = provider.items.take(3).toList();

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Text(
          'home_screen.no_transactions'.tr(),
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.disabledFont,
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _buildTransactionItem(items[index]),
    );
  }

  // --- 3. 개별 거래 아이템 ---
  Widget _buildTransactionItem(Transaction tx) {
    final String title = tx.otherAccountName ?? 'Unknown';
    final int amount = tx.amount.toInt();
    final bool isOutput = tx.category == 'OUTPUT';
    final String dateText = DateFormat('yy.MM.dd HH:mm').format(tx.createdAt);
    final String amountPrefix = isOutput ? '-' : '+';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white.withOpacity(0.4),
              border: Border.all(color: Colors.white.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2E3A59),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateText,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.disabledFont,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$amountPrefix ${CurrencyInputFormatter.format(amount)} ₩',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2E3A59),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 4. 글래스모피즘 버튼 ---
  Widget _buildGlassButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.mainBlue.withOpacity(0.1),
        border: Border.all(color: AppColors.mainBlue.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.mainBlue,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}
