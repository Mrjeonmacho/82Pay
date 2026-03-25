import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bank_model.dart';
import '../providers/bank_provider.dart';
import 'unified_bank_view.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BankProvider>(
      builder: (context, provider, _) {
        // 1. 로딩 중일 때 보여줄 화면
        if (provider.isLoading) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    "은행 데이터를 불러오는 중입니다...",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        // // 2. KR 유저일 때 사업자 정보 요구
        // if (provider.nationality == BankNationality.kr &&
        //     provider.business == null) {
        //   return Scaffold(
        //     body: Center(child: Text("사업자 정보를 찾을 수 없습니다. 다시 시도해 주세요.")),
        //   );
        // }

        // 3. 단일 화면 (KR UI 기반) 렌더링
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: KeyedSubtree(
            key: ValueKey(provider.nationality),
            child: UnifiedBankView(
              nationality: provider.nationality,
              user: provider.user,
              account: provider.account,
              transactions: provider.transactions,
              business: provider.business,
            ),
          ),
        );
      },
    );
  }
}
