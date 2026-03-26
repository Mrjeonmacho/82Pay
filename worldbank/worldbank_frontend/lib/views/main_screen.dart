import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/bank_provider.dart';
import '../providers/auth_provider.dart';
import 'TransactionList.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    // 화면 진입 시 최초 1회 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.userId != null) {
        context.read<BankProvider>().init(auth.userId!, auth.country ?? 'US');
      }
    });
  }

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
      ),
      body: RefreshIndicator(
        color: themeColor,
        onRefresh: () => bank.refreshData(auth.userId ?? 0), // 스와이프 시 갱신
        child: CustomScrollView(
          // 스와이프가 잘 먹히도록 ScrollView 구성
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildAccountCard(
                    color: themeColor,
                    data: bank.accountData,
                    country: bank.userCountry,
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
                ],
              ),
            ),
            // 거래 내역 리스트 (KeyedSubtree로 데이터 변경 시에만 뵤잉 효과)
            SliverFillRemaining(
              hasScrollBody: true,
              child: KeyedSubtree(
                key: ValueKey(bank.listKey),
                child: TransactionList(items: bank.historyList),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard({
    required Color color,
    required Map<String, dynamic>? data,
    required String country,
  }) {
    final num amount = data?['amount'] ?? 0;
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
                data?['userName'] ?? "User",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            data?['accountNumber'] ?? "000-000-000-000",
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 13,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _getCurrencyFormat(country, amount),
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
      case "JP":
        return const Color(0xFFD32F2F);
      case "CN":
        return const Color(0xFFE65100);
      case "US":
        return const Color(0xFF263238);
      default:
        return const Color(0xFF455A64);
    }
  }

  String _getCurrencyFormat(String country, num amount) {
    final formatter = NumberFormat('#,###');
    switch (country) {
      case "KR":
        return "₩${formatter.format(amount)}";
      case "JP":
      case "CN":
        return "¥${formatter.format(amount)}";
      case "US":
        return "\$${formatter.format(amount)}";
      default:
        return formatter.format(amount);
    }
  }
}
