import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:palipay_app/features/history/providers/history_provider.dart';
import 'package:provider/provider.dart';
import 'package:palipay_app/core/utils/route_observers.dart';

// [임포트 확인] 프로젝트 구조에 맞게 UserProvider 경로를 확인하세요.
import 'package:palipay_app/features/home/widgets/empty_wallet_card.dart';
import 'package:palipay_app/features/home/widgets/transactions_section.dart';
import 'package:palipay_app/features/home/widgets/wallet_card.dart';
import 'package:palipay_app/features/account/providers/account_provider.dart';
import 'package:palipay_app/features/wallet/providers/wallet_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  @override
  void initState() {
    super.initState();
    // 초기 로드 시 시도
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAllData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 🚩 RouteObserver 구독
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this); // 🚩 해제
    super.dispose();
  }

  @override
  void didPopNext() {
    // ⭐ 다른 화면(송금 결과 등)에서 홈으로 돌아오면 자동 실행됨
    debugPrint('🔄 [Home] 복귀 감지: 데이터 갱신 시작');
    _refreshAllData();
  }

  void _refreshAllData() {
    final walletProvider = context.read<WalletProvider>();
    final accountProvider = context.read<AccountProvider>();

    // AccountProvider가 단일 출처 — 없으면 0으로 넘기고 서버 응답으로 보완
    final walletId = int.tryParse(accountProvider.walletId ?? '0') ?? 0;
    walletProvider.initWalletData(walletId);

    // walletId 확정 후 히스토리 갱신
    if (walletId > 0) {
      context.read<HistoryProvider>().fetchHistory(walletId: walletId);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.locale;

    // 1. 이제 WalletProvider를 watch합니다.
    final walletProvider = context.watch<WalletProvider>();
    final userProvider = context.watch<UserProvider>();

    // 2. 지갑 유무 판단 기준 변경
    // WalletProvider에 walletId가 저장되어 있고, 서버에서 가져온 지갑 정보(accountNumber)가 있다면 지갑이 있는 것으로 간주합니다.
    final accountProvider = context.watch<AccountProvider>();
    final bool hasWallet = accountProvider.hasWallet;

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      appBar: const PaliTopBar(title: 'PaliPay'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: walletProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    ) // 로딩 중일 때 처리
                  : hasWallet
                  ? WalletCard(provider: walletProvider) // WalletProvider 전달
                  : const EmptyWalletCard(),
            ),
            const TransactionsSection(),
          ],
        ),
      ),
    );
  }
}
