import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // 날짜 포맷팅용
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../providers/history_provider.dart';
import '../models/transaction_model.dart';
import 'history_detail_view.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    // 화면 진입 시 초기 데이터 로드
    Future.microtask(() => context.read<HistoryProvider>().fetchHistory());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HistoryProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PaliTopBar(title: 'History'),
      body: Column(
        children: [
          _buildSpendingSummary(provider),
          _buildFilterChips(),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildTransactionList(provider.items),
          ),
        ],
      ),
    );
  }

  // 상단 지출 요약 카드 (와이어프레임 반영)
  Widget _buildSpendingSummary(HistoryProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Spending', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 8),
          Text(
            '₩ ${provider.items.where((e) => e.category == 'OUTPUT').fold(0.0, (prev, e) => prev + e.amount).toStringAsFixed(0)}',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 필터 칩 영역 (프로토타입 반영)
  Widget _buildFilterChips() {
    final filters = ['All', 'Top-up', 'Payment'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedFilter = filter);
                context.read<HistoryProvider>().fetchHistory(
                  category: filter == 'All' ? null : filter,
                );
              },
              selectedColor: AppColors.mainBlue,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 날짜별 그룹화 리스트
  Widget _buildTransactionList(List<Transaction> items) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        bool showHeader = false;

        // 이전 아이템과 날짜가 다르면 헤더 표시
        if (index == 0 ||
            _isDifferentDay(items[index - 1].createdAt, item.createdAt)) {
          showHeader = true;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader) _buildDateHeader(item.createdAt),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                item.otherAccountName ?? 'Unknown',
                style: AppTextStyles.bodyLarge,
              ),
              subtitle: Text(
                DateFormat('HH:mm').format(item.createdAt),
                style: AppTextStyles.bodySmall,
              ),
              trailing: Text(
                '${item.category == 'OUTPUT' ? '-' : '+'} ₩ ${item.amount.toInt()}',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: item.category == 'OUTPUT'
                      ? Colors.black
                      : AppColors.mainBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => _showDetail(context, item),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        DateFormat('d MMM (EEE)').format(date),
        style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  bool _isDifferentDay(DateTime d1, DateTime d2) {
    return d1.year != d2.year || d1.month != d2.month || d1.day != d2.day;
  }

  void _showDetail(BuildContext context, Transaction item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryDetailView(transaction: item),
      ),
    );
  }
}
