import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart'; // PaliTopBar 포함
import '../providers/account_provider.dart';
import '../models/bank_account_model.dart';

class AccountManagementView extends StatelessWidget {
  const AccountManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    // watch를 사용하여 계좌 상태 변화를 실시간으로 감지합니다.
    final provider = context.watch<AccountProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PaliTopBar(title: 'Account Management'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // 계좌 유무에 따른 조건부 렌더링
            provider.hasWallet
                ? _buildAccountCard(context, provider.linkedAccount!)
                : _buildAddWalletCard(context),
          ],
        ),
      ),
    );
  }

  // 1. 기존 계좌가 있을 때 보여주는 카드 (이미지 95d0c3 반영)
  Widget _buildAccountCard(BuildContext context, BankAccount account) {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF6B7280), // 이미지와 유사한 다크 그레이 톤
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Account',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
          ),
          const Spacer(),
          Text(
            account.accountNumber, // '000-0000-0000' 형태
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: SizedBox(
              width: 60,
              height: 32,
              child: ElevatedButton(
                onPressed: () => _showDeleteDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.8),
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.zero,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text('삭제', style: TextStyle(fontSize: 12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. 계좌가 없을 때 보여주는 점선 카드
  Widget _buildAddWalletCard(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/pin-setting'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          // 실제 점선은 dotted_border 패키지 사용을 권장하며, 기본은 실선으로 구현
          border: Border.all(
            color: AppColors.disabledFont,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                size: 48,
                color: AppColors.mainBlue,
              ),
              SizedBox(height: 12),
              Text(
                'Link New Account',
                style: TextStyle(
                  color: AppColors.disabledFont,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 3. 삭제 확인 다이얼로그
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('계좌 연동 해제'),
        content: const Text('정말로 이 계좌의 연동을 해제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              // TODO: 실제 토큰 연동 필요
              await context.read<AccountProvider>().unlinkAccount("TEMP_TOKEN");
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
