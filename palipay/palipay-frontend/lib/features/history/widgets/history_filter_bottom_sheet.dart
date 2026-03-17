import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/pali_button.dart';

enum HistoryPeriod { full, custom }

enum HistorySortOrder { newest, oldest }

class HistoryFilterBottomSheet extends StatefulWidget {
  const HistoryFilterBottomSheet({super.key});

  @override
  State<HistoryFilterBottomSheet> createState() =>
      _HistoryFilterBottomSheetState();
}

class _HistoryFilterBottomSheetState extends State<HistoryFilterBottomSheet> {
  HistoryPeriod _period = HistoryPeriod.full;
  HistorySortOrder _sortOrder = HistorySortOrder.newest;
  String _transactionType = 'All';
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _customRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: now,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Text(
              'Filter',
              style: AppTextStyles.headlineLarge.copyWith(
                color: AppColors.abledFont,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Period',
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTogglePill(
                  label: 'Full Period',
                  selected: _period == HistoryPeriod.full,
                  onTap: () {
                    setState(() {
                      _period = HistoryPeriod.full;
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildTogglePill(
                  label: 'Custom Period',
                  selected: _period == HistoryPeriod.custom,
                  onTap: () {
                    setState(() {
                      _period = HistoryPeriod.custom;
                    });
                  },
                ),
              ],
            ),
            if (_period == HistoryPeriod.custom) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      label: 'START DATE',
                      value: _formatDate(_customRange!.start),
                      onTap: _pickDateRange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDateField(
                      label: 'END DATE',
                      value: _formatDate(_customRange!.end),
                      onTap: _pickDateRange,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'Transaction Type',
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _transactionType,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: 'All',
                      child: Text('All'),
                    ),
                    DropdownMenuItem(
                      value: 'Top-up',
                      child: Text('Top-up'),
                    ),
                    DropdownMenuItem(
                      value: 'Refund',
                      child: Text('Refund'),
                    ),
                    DropdownMenuItem(
                      value: 'Payment',
                      child: Text('Payment'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _transactionType = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sort Order',
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTogglePill(
                  label: 'Newest',
                  selected: _sortOrder == HistorySortOrder.newest,
                  onTap: () {
                    setState(() {
                      _sortOrder = HistorySortOrder.newest;
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildTogglePill(
                  label: 'Oldest',
                  selected: _sortOrder == HistorySortOrder.oldest,
                  onTap: () {
                    setState(() {
                      _sortOrder = HistorySortOrder.oldest;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            PaliButton(
              text: 'Apply',
              onPressed: () {
                Navigator.pop(context);
              },
              backgroundColor: AppColors.mainBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTogglePill({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.mainBlue : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final initial = _customRange ??
        DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        );

    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.mainBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customRange = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}

