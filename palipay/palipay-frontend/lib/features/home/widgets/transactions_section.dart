import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:palipay_app/features/history/providers/history_provider.dart';
import 'package:palipay_app/features/history/views/history_view.dart';
import 'package:provider/provider.dart';
import 'package:palipay_app/features/account/providers/account_provider.dart';
import '../../../core/utils/currency_input_formatter.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final accountProvider = context.read<AccountProvider>();
      final walletId =
          int.tryParse(accountProvider.linkedAccount?.walletId ?? '0') ?? 0;

      // 💾 walletId가 있을 때만 history 조회 (없으면 에러 방지)
      if (walletId > 0) {
        debugPrint('📝 [TransactionsSection] History 로드 - WalletId: $walletId');
        context.read<HistoryProvider>().fetchHistory(walletId: walletId);
      } else {
        debugPrint('⚠️ [TransactionsSection] WalletId 없음 - History 조회 스킵');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    context.locale; // 다국어 변경을 감지하여 Rebuild 되도록 의존성 주입
    final provider = context.watch<HistoryProvider>();

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: Column(children: [_buildHeader(context), _buildList(provider)]),
    );
  }

  // 헤더: 타이틀 + View all 가로 배치
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'home_screen.recent_transactions'.tr(),
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 18, // 사진과 유사하게
              letterSpacing: -0.5,
              color: const Color(0xFF2E3A59), // 사진의 진한 네이비 컬러
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryView()),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                  child: Container(
                    padding: const EdgeInsets.all(1.0), // 테두리 두께 역할
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.7), // 빛을 받는 부분
                          Colors.white.withOpacity(0.0), // 투명한 그림자 부분
                        ],
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(19),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.4),
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                      ),
                      child: Text(
                        'common.see_all'.tr().toUpperCase(),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFFC75146),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 실제 리스트 뷰
  Widget _buildList(HistoryProvider provider) {
    if (provider.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: CircularProgressIndicator(color: AppColors.mainBlue),
      );
    }

    final items = provider.items.take(5).toList();

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Text(
          'home_screen.no_transactions'.tr(),
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.disabledFont,
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final tx = items[index];
        final String title = tx.otherAccountName ?? 'Unknown';
        final int amount = tx.amount.toInt();
        final bool isOutput = tx.category == 'OUTPUT';
        final String dateText = DateFormat(
          'yy.MM.dd HH:mm',
        ).format(tx.createdAt);

        final amountPrefix = isOutput ? '-' : '+';

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05), // 외곽 그림자
                blurRadius: 24,
                spreadRadius: -5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24), // 그래스모피즘 알약 모서리
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0), // 굴절 강도
              child: Container(
                padding: const EdgeInsets.all(1.5), // 베젤(테두리) 역할을 할 그라데이션 두께
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.8), // 왼쪽 위 하이라이트 (빛)
                      Colors.white.withOpacity(0.0), // 오른쪽 아래 투명 (그림자)
                    ],
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22.5), // 외부 - 테두리 두께
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.35), // 표면의 은은한 반사광
                        Colors.white.withOpacity(0.05), // 깊이감
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: const Color(0xFF2E3A59),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateText, // 포맷팅된 실제 날짜
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.disabledFont,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$amountPrefix ${CurrencyInputFormatter.format(amount)} ₩', // 원화 포맷 적용
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: const Color(0xFF2E3A59),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
