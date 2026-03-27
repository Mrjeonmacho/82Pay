import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// Theme & Utils
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_formatter_util.dart';
import '../../../core/utils/currency_input_formatter.dart';

// Providers & Models
import '../providers/history_provider.dart';
import '../../wallet/providers/wallet_provider.dart';
import '../models/transaction_model.dart';

// Views
import 'history_detail_view.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  bool _isFirstLoad = true;

  @override
  Widget build(BuildContext context) {
    // 🚀 1. WalletProvider와 HistoryProvider를 모두 감시합니다.
    final walletProvider = context.watch<WalletProvider>();
    final historyProvider = context.watch<HistoryProvider>();
    final int? walletId = walletProvider.walletId;

    // 🚀 2. [핵심] walletId가 유효하게 바뀌는 순간 데이터를 처음 불러옵니다.
    if (_isFirstLoad && walletId != null && walletId > 0) {
      _isFirstLoad = false;
      Future.microtask(() {
        if (context.mounted) {
          context.read<HistoryProvider>().fetchHistory(
            walletId: walletId,
            isRefresh: true,
          );
        }
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7), // bgLight
      appBar: AppBar(
        title: Text(
          'history.view.title'.tr(),
          style: AppTextStyles.titleMedium,
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.mainBlue,
      ),
      body: _buildBody(walletId, historyProvider),
    );
  }

  Widget _buildBody(int? walletId, HistoryProvider provider) {
    // 상황 1: 지갑 정보 로딩 중
    if (walletId == null || walletId == 0) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.mainBlue),
      );
    }

    // 상황 2: 내역 로딩 중 (데이터가 아예 없을 때만 로딩바 표시)
    if (provider.isLoading && provider.items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.mainBlue),
      );
    }

    // 상황 3: 내역 없음
    if (provider.items.isEmpty) {
      return Center(
        child: Text(
          'history.no_data'.tr(),
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.disabledFont,
          ),
        ),
      );
    }

    // 상황 4: 내역 있음 (지출 합계 + 날짜별 그룹 리스트)
    final double totalSpent = provider.items
        .where((tx) => tx.category == 'OUTPUT')
        .fold(0, (sum, item) => sum + item.amount);

    return RefreshIndicator(
      onRefresh: () =>
          provider.fetchHistory(walletId: walletId, isRefresh: true),
      child: Column(
        children: [
          _buildSpendingSummary(totalSpent),
          Expanded(child: _buildGroupedCardList(context, provider.items)),
        ],
      ),
    );
  }

  // --- [UI 부분 1: 지출 요약 상단 영역] ---
  Widget _buildSpendingSummary(double totalSpent) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Text(
            'history.view.total_amount_spent'.tr(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.abledFont,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${CurrencyInputFormatter.format(totalSpent.toInt())} ₩',
            style: AppTextStyles.headlineLarge.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.mainBlue,
            ),
          ),
        ],
      ),
    );
  }

  // --- [UI 부분 2: 날짜별 그룹화 카드 리스트] ---
  Widget _buildGroupedCardList(BuildContext context, List<Transaction> items) {
    // 🚀 날짜별 그룹화 로직
    Map<String, List<Transaction>> groups = {};
    for (var item in items) {
      // DateFormatterUtil.formatHistoryHeader가 String을 반환한다고 가정
      String dateKey = DateFormatterUtil.formatHistoryHeader(
        context,
        item.createdAt, // ✅ DateTime이므로 바로 전달
      );
      groups.putIfAbsent(dateKey, () => []).add(item);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        String date = groups.keys.elementAt(index);
        List<Transaction> transactions = groups[date]!;

        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // 카드 상단 날짜 헤더
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 20,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC), // cardHeaderBg
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Text(
                  date,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.abledFont,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 카드 내부 거래 내역 아이템들
              ...transactions.map((tx) => _buildTransactionItem(tx)),
            ],
          ),
        );
      },
    );
  }

  // --- [UI 부분 3: 개별 거래 아이템 위젯] ---
  Widget _buildTransactionItem(Transaction tx) {
    final bool isOutput = tx.category == 'OUTPUT';

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HistoryDetailView(transaction: tx)),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.otherAccountName ?? 'Merchant',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.mainBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  // ✅ tx.createdAt이 DateTime이므로 format에 바로 전달
                  DateFormat.jm(context.locale.toString()).format(tx.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Text(
              '${isOutput ? '-' : '+'} ${CurrencyInputFormatter.format(tx.amount.toInt())} ₩',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isOutput ? AppColors.warningRed : AppColors.mainBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
