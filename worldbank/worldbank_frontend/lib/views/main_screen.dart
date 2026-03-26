import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/bank_provider.dart';
import '../providers/auth_provider.dart';
import 'TransactionList.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bank = context.watch<BankProvider>();
    final auth = context.read<AuthProvider>();

    final themeColor = _getThemeColor(bank.userCountry);

    if (bank.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Image.asset('assets/images/worldlogo2.png', height: 24),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.grey),
            onPressed: () => bank.refreshData(auth.userId ?? 0),
          ),
        ],
      ),
      body: Column(
        children: [
          // 국가 정보를 명시적으로 전달
          _buildAccountCard(
            themeColor,
            bank.accountData,
            "김월드",
            bank.userCountry,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Row(
              children: [
                Text(
                  "history.view.title".tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: KeyedSubtree(
              key: ValueKey(bank.listKey),
              child: TransactionList(items: bank.historyList),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(
    Color color,
    Map<String, dynamic>? data,
    String name,
    String country,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_balance, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    data?['bankName'] ?? "World Bank",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                name,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            data?['accountNumber'] ?? "000-000-000-000",
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            _getCurrencyFormat(country, data?['amount'] ?? 0), // country 변수 사용!
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getThemeColor(String country) {
    switch (country) {
      case "KR":
        return const Color(0xFF1565C0);
      case "US":
        return const Color(0xFF263238);
      case "JP":
        return const Color(0xFFD32F2F);
      case "CN":
        return const Color(0xFFE65100);
      default:
        return const Color(0xFF455A64);
    }
  }

  String _getCurrencyFormat(String country, int amount) {
    final formatter = NumberFormat('#,###');
    switch (country) {
      case "KR":
        return "₩${formatter.format(amount)}";
      case "US":
        return "\$${formatter.format(amount)}";
      case "JP":
        return "¥${formatter.format(amount)}";
      case "CN":
        return "¥${formatter.format(amount)}";
      default:
        return formatter.format(amount);
    }
  }
}
