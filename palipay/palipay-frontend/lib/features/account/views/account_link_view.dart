import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart'; // PaliButton, PaliInputField, PaliTopBar
import '../providers/account_provider.dart';

class AccountLinkView extends StatefulWidget {
  const AccountLinkView({super.key});

  @override
  State<AccountLinkView> createState() => _AccountLinkViewState();
}

class _AccountLinkViewState extends State<AccountLinkView> {
  // 1. 입력을 관리할 컨트롤러 선언
  final _bankController = TextEditingController();
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    // 메모리 누수 방지를 위해 해제
    _bankController.dispose();
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 2. 비동기 연동 로직을 별도 함수로 분리 (VoidCallback 에러 해결)
  Future<void> _handleLinkAccount(BuildContext context) async {
    final accountProvider = context.read<AccountProvider>();

    // 실제 연동 로직 호출 (ERD 명세에 따른 매개변수명 사용)
    final success = await accountProvider.linkAccount(
      bankName: _bankController.text,
      accountNumber: _accountController.text, // accountNum -> accountNumber
      countryCode: 'KR', // country -> countryCode
      password: _passwordController.text,
    );

    // 비동기 작업 후 컨텍스트 유효성 체크 (Async Gap 방지)
    if (!mounted) return;

    if (success) {
      // 연동 성공 시 목록 화면으로 돌아감
      Navigator.pop(context);
    } else {
      // 실패 시 알림 로직
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to link account. Please check your info.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI 업데이트를 감시하기 위해 watch 사용
    final isLoading = context.watch<AccountProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PaliTopBar(title: 'Link Account'), // 64h 공통 상단바
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text('Bank Name', style: AppTextStyles.bodyLarge),
                    const SizedBox(height: 8),
                    PaliInputField(
                      hintText: 'Select your bank',
                      controller: _bankController,
                    ),

                    const SizedBox(height: 24),
                    Text('Account Number', style: AppTextStyles.bodyLarge),
                    const SizedBox(height: 8),
                    PaliInputField(
                      hintText: 'Enter account number (numbers only)',
                      controller: _accountController,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 24),
                    Text('Bank Password', style: AppTextStyles.bodyLarge),
                    const SizedBox(height: 8),
                    PaliInputField(
                      hintText: 'Enter 4-digit password',
                      controller: _passwordController,
                      isPassword: true,
                      maxLength: 4, // 4자리 제한
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),

            // 3. 하단 고정 버튼 (56h 규격)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: PaliButton(
                text: isLoading ? 'Processing...' : 'Verify and Link',
                backgroundColor: AppColors.mainBlue, // #121380 적용
                onPressed: isLoading
                    ? null // 로딩 중 버튼 비활성화
                    : () => _handleLinkAccount(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
