import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:palipay_app/features/home/widgets/transactions_section.dart';
import 'package:palipay_app/features/wallet/views/wallet_refund_view.dart';
import 'package:palipay_app/features/wallet/views/wallet_topup_view.dart';
import 'package:provider/provider.dart';
import 'package:palipay_app/features/account/providers/account_provider.dart';
import 'package:palipay_app/features/account/views/account_management_view.dart';
import 'package:palipay_app/features/pin/views/pin_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final accountProvider = context.watch<AccountProvider>();
    final bool hasWallet = accountProvider.hasWallet;

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      appBar: const PaliTopBar(title: 'PaliPay'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 지갑 카드 (있으면 잔액, 없으면 링크 유도)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: hasWallet
                  ? _buildActiveWalletCard(context, accountProvider)
                  : _buildEmptyWalletCard(context),
            ),

            // 2. 액션 버튼 섹션
            _buildActionButtons(context),

            // 3. 최근 거래 내역 섹션
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Recent Transactions',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.abledFont,
                ),
              ),
            ),
            const TransactionsSection(),
          ],
        ),
      ),
    );
  }

  // --- 여기서부터는 build 메서드 밖입니다 ---
  // --- 추가된 버튼 레이아웃 ---
  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: PaliButton(
              backgroundColor: AppColors.mainBlue,
              text: 'Top-up',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TopupView()),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PaliButton(
              backgroundColor: AppColors.exampleFont,
              textColor: AppColors.abledFont,
              text: 'Refund',
              // 디자인 구분을 위해 아웃라인 스타일이 있다면 적용해도 좋습니다.
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExchangeView()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveWalletCard(
    BuildContext context,
    AccountProvider provider,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AccountManagementView(),
          ),
        );
      },
      child: PaliBalanceCard(
        krwAmount: '₩ ${provider.linkedAccount?.amount ?? 0}',
      ),
    );
  }

  Widget _buildEmptyWalletCard(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PinScreen(mode: PinMode.create),
        ),
      ),
      borderRadius: BorderRadius.circular(20),
      child: CustomPaint(
        painter: DashedRectPainter(color: AppColors.exampleFont),
        child: Container(
          width: double.infinity,
          height: 180,
          // alignment: MainAxisAlignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_circle_outline,
                size: 48,
                color: AppColors.mainBlue,
              ),
              const SizedBox(height: 12),
              Text(
                'Link your bank account',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.abledFont,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 점선을 그리기 위한 Painter ---
class DashedRectPainter extends CustomPainter {
  final Color color;
  DashedRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 5, dashSpace = 5, startX = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final RRect rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(20),
    );

    Path path = Path()..addRRect(rRect);

    // 점선 효과 구현
    for (PathMetric pathMetric in path.computeMetrics()) {
      while (startX < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(startX, startX + dashWidth),
          paint,
        );
        startX += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
