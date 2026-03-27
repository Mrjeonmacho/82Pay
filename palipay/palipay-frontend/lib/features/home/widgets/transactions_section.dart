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
  // 🚀 한 번 불러왔으면 다시 부르지 않게 막아주는 플래그
  bool _hasFetched = false;

  @override
  Widget build(BuildContext context) {
    // 1. WalletProvider를 'watch'해서 데이터 변화를 계속 지켜봅니다.
    final walletProvider = context.watch<WalletProvider>();
    final walletId = walletProvider.walletId;

    // 2. [핵심 로직] walletId가 드디어 0보다 큰 '진짜 값'이 되었을 때!
    if (!_hasFetched && walletId != null && walletId > 0) {
      _hasFetched = true; // "이제 불러왔어!"라고 표시

      // build 도중에 다른 Provider를 수정하면 에러가 날 수 있으므로 microtask 사용
      Future.microtask(() {
        if (context.mounted) {
          debugPrint(
            '🎯 [TransactionsSection] walletId 발견($walletId)! 내역 조회를 시작합니다.',
          );
          context.read<HistoryProvider>().fetchHistory(walletId: walletId);
        }
      });
    }

    final historyProvider = context.watch<HistoryProvider>();

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: Column(
        children: [_buildHeader(context), _buildList(historyProvider)],
      ),
    );
  }

  // --- 1. 헤더 영역 (최근 내역 + 전체보기) ---
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
              letterSpacing: -0.5,
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

    // 최근 5개만 노출
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
      itemBuilder: (context, index) {
        final tx = items[index];
        return _buildTransactionItem(tx);
      },
    );
  }

  // --- 3. 개별 거래 아이템 위젯 (그래스모피즘) ---
  Widget _buildTransactionItem(Transaction tx) {
    final String title = tx.otherAccountName ?? 'Unknown';
    final int amount = tx.amount.toInt();
    final bool isOutput = tx.category == 'OUTPUT';

    // ✅ tx.createdAt이 DateTime이므로 에러 없이 바로 포맷팅 가능
    final String dateText = DateFormat('yy.MM.dd HH:mm').format(tx.createdAt);
    final String amountPrefix = isOutput ? '-' : '+';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 24,
            spreadRadius: -5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
          child: Container(
            padding: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.8),
                  Colors.white.withOpacity(0.0),
                ],
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22.5),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.35),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: const Color(0xFF2E3A59),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateText,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.disabledFont,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$amountPrefix ${CurrencyInputFormatter.format(amount)} ₩',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: const Color(0xFF2E3A59),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- 4. 그래스모피즘 스타일의 "See All" 버튼 ---
  Widget _buildGlassButton(String text) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.4),
                Colors.white.withOpacity(0.1),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
          ),
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFFC75146),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
