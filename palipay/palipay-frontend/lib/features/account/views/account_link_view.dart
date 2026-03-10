import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../providers/account_provider.dart';

class AccountLinkView extends StatefulWidget {
  const AccountLinkView({super.key});

  @override
  State<AccountLinkView> createState() => _AccountLinkViewState();
}

class _AccountLinkViewState extends State<AccountLinkView> {
  final _walletIdController = TextEditingController();
  final _bankCodeController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountController = TextEditingController();
  final _usernameController = TextEditingController();
  final _moneyCodeController = TextEditingController();
  final _passwordController = TextEditingController(); // 계좌 비밀번호 추가

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 1. BankSelectionView에서 넘겨준 인자(Arguments) 받기
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    if (args != null) {
      _bankNameController.text = args['bankName'] ?? '';
      _bankCodeController.text = args['bankCode'] ?? '';
    }
  }

  @override
  void dispose() {
    _walletIdController.dispose();
    _bankCodeController.dispose();
    _bankNameController.dispose();
    _accountController.dispose();
    _usernameController.dispose();
    _moneyCodeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLinkAccount() async {
    final accountProvider = context.read<AccountProvider>();
    const String accessToken = "USER_OAUTH_TOKEN_EXAMPLE";

    final success = await accountProvider.linkAccount(
      walletId: _walletIdController.text,
      bankCode: _bankCodeController.text,
      bankName: _bankNameController.text,
      accountNumber: _accountController.text,
      accountUsername: _usernameController.text,
      moneyCode: _moneyCodeController.text.toUpperCase(),
      // password: _passwordController.text, // 명세서 업데이트 시 추가
      token: accessToken,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account linked successfully!')),
      );
      // 8번 완료 화면으로 이동하거나 이전으로 돌아감
      Navigator.popUntil(context, ModalRoute.withName('/'));
    } else {
      _showErrorSnackBar('Link failed. Please check your information.');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AccountProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PaliTopBar(title: 'Link Account'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Bank & Wallet'),
                    Row(
                      children: [
                        Expanded(
                          child: PaliInputField(
                            controller: _bankNameController,
                            hintText: 'Bank',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: PaliInputField(
                            controller: _walletIdController,
                            hintText: 'Wallet ID',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _buildSectionTitle('Account Holder'),
                    PaliInputField(
                      hintText: 'Full Name',
                      controller: _usernameController,
                    ),
                    const SizedBox(height: 24),

                    _buildSectionTitle('Account Details'),
                    PaliInputField(
                      hintText: 'Account Number',
                      controller: _accountController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    // 계좌 비밀번호 필드 (기획안 7번 반영)
                    PaliInputField(
                      hintText: '4-digit Bank Password',
                      controller: _passwordController,
                      isPassword: true,
                      maxLength: 4,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),

                    _buildSectionTitle('Currency'),
                    PaliInputField(
                      hintText: 'e.g., USD, KRW',
                      controller: _moneyCodeController,
                      maxLength: 3,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: PaliButton(
                text: isLoading ? 'Processing...' : 'Verify and Link',
                backgroundColor: AppColors.mainBlue,
                onPressed: isLoading ? null : _handleLinkAccount,
              ),
            ),
          ],
        ),
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
