import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../core/constant/bank_constant.dart';

class TransactionList extends StatelessWidget {
  final List<dynamic> items;

  const TransactionList({super.key, required this.items});

  String _getBankLogo(String? bankCode) {
    if (bankCode == null) return 'assets/images/default_bank.png';
    for (var country in BankConstants.countryData.values) {
      for (var bank in country['banks']) {
        if (bank['bankCode'] == bankCode) return bank['logo'];
      }
    }
    return 'assets/images/default_bank.png';
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          // 데이터 없을 때도 스와이프 되도록
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Center(
              child: Text(
                "history.empty".tr(),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      // ⭐ 중요: 데이터가 적어도 스와이프(Refresh)가 작동하게 함
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      itemBuilder: (context, index) {
        final item = items[index];

        return TweenAnimationBuilder(
          key: ValueKey(item['historyId']),
          duration: const Duration(milliseconds: 600),
          tween: Tween<double>(begin: 1.0, end: 0.0),
          curve: Curves.easeOutBack,
          builder: (context, double value, child) {
            return Transform.translate(
              offset: Offset(0, value * -20),
              child: Opacity(
                // 🛑 Opacity 에러 방지용 clamp
                opacity: (1 - value).clamp(0.0, 1.0),
                child: child,
              ),
            );
          },
          child: _buildItem(item),
        );
      },
    );
  }

  Widget _buildItem(dynamic item) {
    final bool isInput = item['category'] == 'INPUT';
    final String dateStr = item['createdAt']?.toString().split('T')[0] ?? "";
    final String bankLogo = _getBankLogo(item['otherBankCode']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFF5F5F5),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                bankLogo,
                errorBuilder: (c, e, s) => const Icon(
                  Icons.account_balance,
                  size: 20,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['otherAccountName'] ?? "Unknown",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            "${isInput ? '+' : '-'}${NumberFormat('#,###').format(item['amount'])}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isInput ? Colors.blue[700] : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
