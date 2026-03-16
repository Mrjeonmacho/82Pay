import 'package:flutter/material.dart';
import 'package:palipay_app/features/home/widgets/empty_wallet_card.dart';
import 'package:palipay_app/features/home/widgets/transactions_section.dart';
import 'package:palipay_app/features/home/widgets/wallet_card.dart';
import 'package:provider/provider.dart';
import 'package:palipay_app/features/account/providers/account_provider.dart';
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
                  ? WalletCard(provider: accountProvider) // 분리된 위젯 사용
                  : const EmptyWalletCard(),
            ),

            // 2. 액션 버튼 섹션
            // _buildActionButtons(context),

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

  //   // --- 여기서부터는 build 메서드 밖입니다 ---
  //   // 1. 활성화된 지갑 카드 (그라데이션 디자인 반영)
  //   Widget _buildActiveWalletCard(
  //     BuildContext context,
  //     AccountProvider provider,
  //   ) {
  //     return GestureDetector(
  //       onTap: () {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => const AccountManagementView(),
  //           ),
  //         );
  //       },
  //       child: Container(
  //         width: double.infinity,
  //         height: 200, // 시안의 비율에 맞춰 높이 조절
  //         padding: const EdgeInsets.all(24),
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(24),
  //           // 시안의 선명한 레드-블루 그라데이션 적용
  //           gradient: const LinearGradient(
  //             // 시안의 느낌을 더 살리기 위해 시작점을 약간 더 위쪽/왼쪽으로 이동
  //             begin: Alignment(-0.8, -1.0),
  //             end: Alignment(0.8, 1.0),
  //             colors: [
  //               AppColors.warningRed, // 시안의 레드/핑크 계열
  //               AppColors.mainBlue, // 시안의 딥 블루 계열
  //             ],
  //             // 색상이 바뀌는 지점
  //             stops: [0.2, 0.9],
  //           ),
  //           boxShadow: [
  //             BoxShadow(
  //               color: AppColors.mainBlue.withOpacity(0.3),
  //               blurRadius: 20,
  //               offset: const Offset(0, 10),
  //             ),
  //           ],
  //         ),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             // 상단 영역: 라벨 및 아이콘
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   'Main Wallet',
  //                   style: AppTextStyles.bodyMedium.copyWith(
  //                     color: Colors.white.withOpacity(0.8),
  //                     fontWeight: FontWeight.w500,
  //                   ),
  //                 ),
  //                 Container(
  //                   padding: const EdgeInsets.all(8),
  //                   decoration: BoxDecoration(
  //                     color: Colors.white.withOpacity(0.2),
  //                     shape: BoxShape.circle,
  //                   ),
  //                   child: const Icon(
  //                     Icons.account_balance_wallet,
  //                     color: Colors.white,
  //                     size: 18,
  //                   ),
  //                 ),
  //               ],
  //             ),

  //             // 중앙 영역: 잔액 표시
  //             Text(
  //               '₩ ${provider.linkedAccount?.amount ?? 0}',
  //               style: AppTextStyles.titleMedium.copyWith(
  //                 color: Colors.white,
  //                 fontWeight: FontWeight.bold,
  //                 fontSize: 32,
  //               ),
  //             ),

  //             // 하단 영역: 홀더 이름 및 액션 버튼
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               crossAxisAlignment: CrossAxisAlignment.end,
  //               children: [
  //                 Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       'CARD HOLDER',
  //                       style: AppTextStyles.bodySmall.copyWith(
  //                         color: Colors.white.withOpacity(0.6),
  //                         fontSize: 10,
  //                       ),
  //                     ),
  //                     const SizedBox(height: 4),
  //                     Text(
  //                       'ALEX JOHNSON', // 실제 데이터 연결 시 provider 활용
  //                       style: AppTextStyles.bodyLarge.copyWith(
  //                         color: Colors.white,
  //                         fontWeight: FontWeight.w600,
  //                         letterSpacing: 1.1,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 // ADD MONEY 버튼 (반투명 스타일)
  //                 Material(
  //                   color: Colors.transparent,
  //                   child: InkWell(
  //                     onTap: () {
  //                       Navigator.push(
  //                         context,
  //                         MaterialPageRoute(
  //                           builder: (context) => const TopupView(),
  //                         ),
  //                       );
  //                     },
  //                     borderRadius: BorderRadius.circular(12),
  //                     child: Container(
  //                       padding: const EdgeInsets.symmetric(
  //                         horizontal: 16,
  //                         vertical: 10,
  //                       ),
  //                       decoration: BoxDecoration(
  //                         color: Colors.white.withOpacity(0.2),
  //                         borderRadius: BorderRadius.circular(12),
  //                       ),
  //                       child: Text(
  //                         'ADD MONEY',
  //                         style: AppTextStyles.bodySmall.copyWith(
  //                           color: Colors.white,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }

  //   Widget _buildEmptyWalletCard(BuildContext context) {
  //     return InkWell(
  //       onTap: () => Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => const PinScreen(mode: PinMode.create),
  //         ),
  //       ),
  //       borderRadius: BorderRadius.circular(20),
  //       child: CustomPaint(
  //         painter: DashedRectPainter(color: AppColors.exampleFont),
  //         child: Container(
  //           width: double.infinity,
  //           height: 180,
  //           // alignment: MainAxisAlignment.center,
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               const Icon(
  //                 Icons.add_circle_outline,
  //                 size: 48,
  //                 color: AppColors.mainBlue,
  //               ),
  //               const SizedBox(height: 12),
  //               Text(
  //                 'Link your bank account',
  //                 style: AppTextStyles.bodyMedium.copyWith(
  //                   color: AppColors.abledFont,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     );
  //   }
  // }

  // // --- 점선을 그리기 위한 Painter ---
  // class DashedRectPainter extends CustomPainter {
  //   final Color color;
  //   DashedRectPainter({required this.color});

  //   @override
  //   void paint(Canvas canvas, Size size) {
  //     double dashWidth = 5, dashSpace = 5, startX = 0;
  //     final paint = Paint()
  //       ..color = color
  //       ..strokeWidth = 2
  //       ..style = PaintingStyle.stroke;

  //     final RRect rRect = RRect.fromRectAndRadius(
  //       Rect.fromLTWH(0, 0, size.width, size.height),
  //       const Radius.circular(20),
  //     );

  //     Path path = Path()..addRRect(rRect);

  //     // 점선 효과 구현
  //     for (PathMetric pathMetric in path.computeMetrics()) {
  //       while (startX < pathMetric.length) {
  //         canvas.drawPath(
  //           pathMetric.extractPath(startX, startX + dashWidth),
  //           paint,
  //         );
  //         startX += dashWidth + dashSpace;
  //       }
  //     }
  //   }

  //   @override
  //   bool shouldRepaint(CustomPainter oldDelegate) => false;
}
