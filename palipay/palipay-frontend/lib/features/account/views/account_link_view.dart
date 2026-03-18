import 'package:flutter/material.dart';
import 'package:palipay_app/features/account/views/bank_password_view.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../providers/account_provider.dart';

class AccountLinkView extends StatefulWidget {
  // 생성자를 통해 선택된 은행 정보를 직접 받습니다.
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
  // 이제 컨트롤러는 딱 두 개만 필요합니다.
  final _accountController = TextEditingController();
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _accountController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _handleNextStep() {
    // 1. 유효성 검사
    if (_usernameController.text.isEmpty || _accountController.text.isEmpty) {
      _showErrorSnackBar('Please fill in all fields.');
      return;
    }

    // 2. [기획 반영] 다음 페이지(계좌 비밀번호 입력)로 이동
    // 여기서 입력된 정보들을 넘겨줍니다.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BankPasswordView(
          bankName: widget.bankName,
          bankCode: widget.bankCode,
          accountNumber: _accountController.text,
          accountUsername: _usernameController.text,
          // currency는 UserProvider 등에서 가져온다고 가정
          currency: 'KRW',
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
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
                    // 현재 선택된 은행을 시각적으로 명확히 보여줌 (수정 불가)
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

                    _buildSectionTitle('Account Number'),
                    PaliInputField(
                      hintText: 'Enter account number (digits only)',
                      controller: _accountController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your currency will be set to KRW based on your profile.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.exampleFont,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: PaliButton(
                text: 'Next',
                backgroundColor: AppColors.mainBlue,
                onPressed: _handleNextStep,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 고정된 정보를 보여주는 위젯 (은행 이름 등)
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
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.exampleFont,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
