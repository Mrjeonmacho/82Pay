import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // 날짜 포맷팅용
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../providers/history_provider.dart';
import '../../account/providers/account_provider.dart';
import '../models/transaction_model.dart';
import 'history_detail_view.dart';
import '../../../core/utils/date_formatter_util.dart';
import '../../../core/utils/currency_input_formatter.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});
  static const Color bgLight = Color(0xFFF2F4F7);
  static const Color cardHeaderBg = Color(0xFFF8FAFC);

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  @override
  void initState() {
    super.initState();
    // 화면 진입 시 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final accountProvider = context.read<AccountProvider>();
      final walletId =
          int.tryParse(accountProvider.linkedAccount?.walletId ?? '0') ?? 0;
      context.read<HistoryProvider>().fetchHistory(walletId: walletId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HistoryProvider>();

    // OUTPUT(지출) 총합 계산
    final totalSpent = provider.items
        .where((e) => e.category == 'OUTPUT')
        .fold(0.0, (prev, e) => prev + e.amount);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PaliTopBar(title: 'history.view.title'.tr()),
      body: Column(
        children: [
          // 1. 상단 총 지출 요약 영역
          // 1. 상단 총 지출 요약 영역 (Style Guide 적용)
          _buildSpendingSummary(totalSpent),

          // 2. 날짜별 그룹화 카드 리스트
          Expanded(
            child: provider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.mainBlue),
                  )
                : _buildGroupedCardList(context, provider.items),
          ),
        ],
      ),
    );
  }

  // 상단 요약 영역 분리 및 스타일 적용
  Widget _buildSpendingSummary(double totalSpent) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Text(
            'history.view.total_amount_spent'.tr(),
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.mainBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${CurrencyInputFormatter.format(totalSpent.toInt())} ₩',
            style: AppTextStyles.headlineLarge.copyWith(
              fontSize: 28,
              color: AppColors.mainBlue,
            ),
          ),
        ],
      ),
    );
  }

  // 데이터를 날짜별로 묶어서 카드로 렌더링
  Widget _buildGroupedCardList(BuildContext context, List<Transaction> items) {
    // 날짜별 그룹화 로직
    Map<String, List<Transaction>> groups = {};
    for (var item in items) {
      String dateKey = DateFormatterUtil.formatHistoryHeader(
        context,
        item.createdAt,
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
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Text(
                  date,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.abledFont,
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mainBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
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
                fontWeight: FontWeight.bold,
                color: isOutput ? AppColors.warningRed : AppColors.mainBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
