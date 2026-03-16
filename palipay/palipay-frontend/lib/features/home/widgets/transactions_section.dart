import 'package:flutter/material.dart';
import 'package:palipay_app/features/history/providers/history_provider.dart';
import 'package:palipay_app/features/history/views/history_view.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class TransactionsSection extends StatefulWidget {
  const TransactionsSection({super.key});

  @override
  State<TransactionsSection> createState() => _TransactionsSectionState();
}

class _TransactionsSectionState extends State<TransactionsSection> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HistoryProvider>();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          _buildFilterToggle(provider),
          _buildList(provider),
        ],
      ),
    );
  }

  // 헤더: 타이틀 + See all
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryView()),
            ),
            child: Text(
              'See all',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mainBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 필터 토글 (All, Top-up, Payment)
  Widget _buildFilterToggle(HistoryProvider provider) {
    final filters = ['All', 'Top-up', 'Payment'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedFilter = filter);
                // API 명세에 따른 카테고리 매핑
                String? category;
                if (filter == 'Top-up') category = 'INPUT';
                if (filter == 'Payment') category = 'OUTPUT';
                provider.fetchHistory(category: category);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    filter,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected ? Colors.black : AppColors.abledFont,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 실제 리스트 뷰
  Widget _buildList(HistoryProvider provider) {
    if (provider.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: CircularProgressIndicator(),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: provider.items.length,
      itemBuilder: (context, index) {
        final item = provider.items[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              _buildIcon(item.category),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.otherAccountName ?? 'Unknown',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Today, 2:30 PM',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.abledFont,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${item.category == 'OUTPUT' ? '-' : '+'} ${item.amount.toInt()} ₩',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIcon(String category) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: AppColors.background,
        shape: BoxShape.circle,
      ),
      child: Icon(
        category == 'OUTPUT'
            ? Icons.shopping_bag_outlined
            : Icons.account_balance_wallet_outlined,
        color: AppColors.abledFont,
        size: 24,
      ),
    );
  }
}
