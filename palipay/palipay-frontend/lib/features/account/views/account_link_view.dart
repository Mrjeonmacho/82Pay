import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../providers/account_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/constants/bank_constants.dart';
import 'bank_password_view.dart';
import 'package:flutter/services.dart';

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

  // ✅ 숫자 12자리만 유효
  bool get _isAccountValid =>
      RegExp(r'^\d{12}$').hasMatch(_accountController.text.replaceAll('-', ''));

  @override
  void dispose() {
    _accountController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.warningRed),
    );
  }

  Future<void> _handleNextStep() async {
    if (!_isAccountValid) {
      _showErrorSnackBar('account_link.msg_invalid_account_format'.tr());
      return;
    }

    if (_usernameController.text.isEmpty) {
      _showErrorSnackBar('account_link.fill_all_fields'.tr());
      return;
    }

    // ✅ 국가코드 기반으로 통화코드 자동 결정
    final countryCode = context.read<UserProvider>().countryCode ?? 'US';
    final moneyCode = BankConstants.getDefaultCurrency(countryCode);

    final partialData = {
      "bankCode": widget.bankCode,
      "accountNumber": _accountController.text.replaceAll('-', ''),
      "accountUsername": _usernameController.text.trim(),
      "moneyCode": moneyCode,
    };

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BankPasswordView(
            partialData: partialData,
            bankName: widget.bankName,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AccountProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PaliTopBar(title: 'account_link.title'.tr()),
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
                      'account_link.selected_bank'.tr(),
                      widget.bankName,
                      Icons.account_balance,
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle('account_link.account_holder'.tr()),
                    PaliInputField(
                      hintText: 'account_link.enter_full_name'.tr(),
                      controller: _usernameController,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('account_input.account_number'.tr()),
                    _CustomAccountInput(
                      controller: _accountController,
                      onChanged: (val) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'account_link.currency_info'.tr(),
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
                text: isLoading
                    ? 'account_link.linking'.tr()
                    : 'account_link.link_account'.tr(),
                backgroundColor: (isLoading || !_isAccountValid)
                    ? AppColors.disabledBackground
                    : AppColors.mainBlue,
                onPressed: (isLoading || !_isAccountValid)
                    ? null
                    : _handleNextStep,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          Expanded(
            child: Column(
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
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
              ],
            ),
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

class _CustomAccountInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const _CustomAccountInput({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      // ✅ 숫자 키패드
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(12),
        _AccountNumberFormatter(),
      ],
      decoration: InputDecoration(
        hintText: '0000-0000-0000',
        filled: true,
        fillColor: const Color(0xFFF8F8FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}

// ✅ 숫자 4자리마다 하이픈 자동 삽입 (표시용: 0000-0000-0000)
class _AccountNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll('-', '');
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      // 4자리, 8자리 뒤에 하이픈 (마지막 뒤에는 안 붙임)
      if ((i == 3 || i == 7) && i != digits.length - 1) {
        buffer.write('-');
      }
    }

    final result = buffer.toString();
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}
