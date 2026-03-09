import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart'; // 모든 공통 위젯 포함

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // 하단 바 돌출 버튼이 배경과 자연스럽게 어우러지도록 설정
      backgroundColor: AppColors.background, // #F5F5F8 적용
      // 1. 커스텀 상단바 (64h)
      appBar: const PaliTopBar(title: 'PaliPay'),

      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100), // 하단바에 가려지지 않게 여백 추가
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2. 메인 잔액 카드 (그라데이션 및 Title Large 적용)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: PaliBalanceCard(
                krwAmount: '₩ 1,250,000',
                usdAmount: '942.50',
              ),
            ),

            // 3. 섹션 타이틀 (Body Large 적용)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Recent Transactions',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.abledFont,
                ),
              ),
            ),

            // 4. 거래 내역 리스트 (PaliTransactionTile 활용)
            Container(
              color: Colors.white,
              child: Column(
                children: const [
                  PaliTransactionList(
                    storeName: 'Starbucks Gangnam',
                    time: 'Today, 14:20',
                    amount: '5,500',
                    isCharge: false, // 지출 (#2F2929)
                  ),
                  Divider(height: 1, indent: 20, endIndent: 20),
                  PaliTransactionList(
                    storeName: 'Wallet Top-up',
                    time: 'Yesterday, 10:00',
                    amount: '50,000',
                    isCharge: true, // 충전 (#2426D3)
                  ),
                  Divider(height: 1, indent: 20, endIndent: 20),
                  PaliTransactionList(
                    storeName: 'Public Transport',
                    time: 'March 08, 08:30',
                    amount: '1,250',
                    isCharge: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // 5. 돌출형 하단 내비게이션 바
      bottomNavigationBar: PaliBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // index 2 (Scan) 클릭 시 OCR 화면으로 이동 로직 추가 가능
        },
      ),
    );
  }
}
