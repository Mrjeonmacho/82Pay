// 외부 계좌 유무 확인 및 삭제만 가능
// 등록: 계좌 번호/비밀번호 입력 -> 연동 완료
// 삭제: 정말 삭제하시겠습니까? 확인 로직 -> 삭제 완료

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart'; // PaliButton, PaliTopBar 등
import '../providers/account_provider.dart';
import 'account_link_view.dart';

class AccountListView extends StatelessWidget {
  const AccountListView({super.key});

  @override
  Widget build(BuildContext context) {
    // AccountProvider에서 연동된 계좌 정보를 가져옵니다.
    final accountProvider = Provider.of<AccountProvider>(context);
    final linkedAccount = accountProvider.linkedAccount;

    return Scaffold(
      appBar: const PaliTopBar(title: 'Bank Account'),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              linkedAccount == null ? 'No account linked' : 'Linked Account',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.abledFont,
              ),
            ),
            const SizedBox(height: 16),

            // 1. 계좌 상태에 따른 본문 렌더링
            Expanded(
              child: linkedAccount == null
                  ? _buildEmptyState(context) // 계좌가 없을 때
                  : _buildAccountCard(context, linkedAccount), // 계좌가 있을 때
            ),

            // 2. 계좌 상태에 따른 하단 버튼 (등록 vs 삭제)
            linkedAccount == null
                ? PaliButton(
                    text: 'Link New Account',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AccountLinkView(),
                      ),
                    ),
                    backgroundColor: AppColors.background,
                  )
                : PaliButton(
                    text: 'Delete Account',
                    backgroundColor: AppColors.warningRed, // 삭제는 빨간색 포인트 컬러
                    onPressed: () =>
                        _showDeleteDialog(context, accountProvider),
                  ),
          ],
        ),
      ),
    );
  }

  // 계좌가 없을 때 보여줄 안내 UI
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_outlined,
            size: 64,
            color: AppColors.exampleFont,
          ),
          const SizedBox(height: 16),
          const Text(
            'Link an external bank account\nto start charging your wallet.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF524848), fontSize: 16),
          ),
        ],
      ),
    );
  }

  // 연동된 계좌 정보를 보여주는 카드 UI
  Widget _buildAccountCard(BuildContext context, dynamic account) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(account.bankName, style: AppTextStyles.bodyLarge),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  account.countryCode,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            account.accountNumber,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.exampleFont,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${account.amount} ${account.countryCode == 'KR' ? '₩' : '\$'}',
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.mainBlue),
          ),
        ],
      ),
    );
  }

  // 삭제 확인 팝업
  void _showDeleteDialog(BuildContext context, AccountProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to unlink this account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.unlinkAccount(); // FINANCE_002 API 호출 대응
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.warningRed),
            ),
          ),
        ],
      ),
    );
  }
}
