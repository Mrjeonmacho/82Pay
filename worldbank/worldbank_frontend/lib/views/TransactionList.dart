import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // tr() 사용을 위해 필요
import '../core/constant/bank_constant.dart';

class TransactionList extends StatelessWidget {
  final List<dynamic> items;

  const TransactionList({super.key, required this.items});

  // 은행 코드로 로고 경로를 찾아주는 헬퍼 함수
  String _getBankLogo(String? bankCode) {
    if (bankCode == null) return 'assets/images/default_bank.png';

    for (var country in BankConstants.countryData.values) {
      for (var bank in country['banks']) {
        if (bank['bankCode'] == bankCode) {
          return bank['logo'];
        }
      }
    }
    return 'assets/images/default_bank.png';
  }

  @override
  Widget build(BuildContext context) {
    // --- 추가된 부분: 데이터가 없을 때 ---
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_late_outlined,
              size: 60,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              "history.empty".tr(), // 번역 키 적용
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // --- 데이터가 있을 때는 기존 애니메이션 리스트 출력 ---
    return ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemBuilder: (context, index) {
        final item = items[index];
        final String bankLogo = _getBankLogo(item['bankCode']);
        final bool isDeposit = item['type'] == 'DEPOSIT';

        return TweenAnimationBuilder(
          duration: Duration(milliseconds: 500 + (index * 100)),
          tween: Tween<double>(begin: 1.0, end: 0.0),
          curve: Curves.elasticOut,
          builder: (context, double value, child) {
            return Transform.translate(
              offset: Offset(0, value * 100),
              child: Opacity(opacity: 1 - value, child: child),
            );
          },
          child: Container(
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
                      errorBuilder: (c, e, s) =>
                          const Icon(Icons.account_balance, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['targetName'] ?? "Unknown",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['createdAt']?.toString().split('T')[0] ?? "",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "${isDeposit ? '+' : '-'}${item['amount']}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDeposit ? Colors.blue : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
