import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../providers/account_provider.dart';
import '../../../core/providers/user_provider.dart'; 
import 'bank_password_view.dart';

class AccountLinkView extends StatefulWidget {
  final String bankName;
  final String bankCode;
  

  const AccountLinkView({
    super.key,
    required this.bankName,
    required this.bankCode,
  });

  @override
  State<AccountLinkView> createState() => _AccountLinkViewState();
}

class _AccountLinkViewState extends State<AccountLinkView> {
  final _accountController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _accountController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 1. 스낵바 메서드 정의 (클래스 내부)
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.warningRed),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  // 2. 계좌 연동 처리 로직
  Future<void> _handleNextStep() async {
  if (_usernameController.text.isEmpty || _accountController.text.isEmpty) {
    _showErrorSnackBar('모든 필드를 입력해주세요.');
    return;
  }

  // 다음 화면으로 넘길 데이터 뭉치
  final partialData = {
    "bankCode": widget.bankCode,
    "accountNumber": _accountController.text.trim(),
    "accountUsername": _usernameController.text.trim(),
    "moneyCode": "KRW",
  };

  // 💡 비밀번호 입력 화면으로 이동
  if (mounted) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BankPasswordView(partialData: partialData, bankName: widget.bankName),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AccountProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PaliTopBar(title: 'Account Information'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFixedInfoTile(
                      'Selected Bank',
                      widget.bankName,
                      Icons.account_balance,
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Account Holder'),
                    PaliInputField(
                      hintText: 'Enter full name',
                      controller: _usernameController,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('account_input.account_number'.tr()),
                    PaliInputField(
                      hintText: 'Enter account number',
                      controller: _accountController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'account_link.currency_info'.tr(),
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.exampleFont),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: PaliButton(
                text: isLoading ? 'Linking...' : 'Link Account',
                backgroundColor: isLoading ? AppColors.disabledBackground : AppColors.mainBlue,
                onPressed: isLoading ? null : _handleNextStep,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. 헬퍼 위젯들 (클래스 내부)
  Widget _buildFixedInfoTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.mainBlue),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.exampleFont)),
              Text(value, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
    );
  }
}