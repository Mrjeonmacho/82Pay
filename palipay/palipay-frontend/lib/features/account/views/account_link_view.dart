import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../providers/account_provider.dart';
import '../../../core/providers/user_provider.dart';
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
  final _passwordController = TextEditingController();

  bool get _isAccountValid =>
      RegExp(r'^[A-Z]{2}-\d{4}-\d{4}-\d{4}$').hasMatch(_accountController.text);

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
    // 💡 형식 체크 추가
    if (!_isAccountValid) {
      _showErrorSnackBar('account_link.msg_invalid_account_format'.tr());
      return;
    }

    if (_usernameController.text.isEmpty || _accountController.text.isEmpty) {
      _showErrorSnackBar('account_link.fill_all_fields'.tr());
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
                    // 💡 공통 위젯 대신 여기서 만든 커스텀 필드 사용
                    _CustomAccountInput(
                      controller: _accountController,
                      onChanged: (val) => setState(() {}), // 버튼 활성화를 위해 상태 갱신
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
                // 💡 형식이 맞을 때만 버튼 활성화 (선택 사항)
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
          // 💡 핵심: Column을 Expanded로 감싸서 남은 가로 공간만 쓰게 합니다.
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
                  // 💡 추가: 텍스트가 너무 길면 '...' 처리하고 최대 1줄만 허용
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
      // 💡 문자2개-숫자12개 포매터 적용
      inputFormatters: [
        _AccountNumberFormatter(),
        LengthLimitingTextInputFormatter(17), // AA-0000-0000-0000 총 17자
      ],
      decoration: InputDecoration(
        hintText: 'KR-0000-0000-0000',
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

// 💡 하이픈 자동 삽입 포매터
class _AccountNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.toUpperCase();
    if (text.length < oldValue.text.length) return newValue; // 백스페이스 허용

    final cleanText = text.replaceAll(RegExp(r'[^A-Z0-9]'), '');
    StringBuffer buffer = StringBuffer();

    for (int i = 0; i < cleanText.length; i++) {
      // 0~1번 인덱스는 문자만, 나머지는 숫자만 (정교한 제한)
      if (i < 2) {
        if (RegExp(r'[A-Z]').hasMatch(cleanText[i])) buffer.write(cleanText[i]);
      } else {
        if (RegExp(r'[0-9]').hasMatch(cleanText[i])) buffer.write(cleanText[i]);
      }

      // 하이픈 위치: 2자, 6자, 10자 뒤
      if (cleanText.length > 2 && i == 1) buffer.write('-');
      if (cleanText.length > 6 && i == 5) buffer.write('-');
      if (cleanText.length > 10 && i == 9) buffer.write('-');
    }

    final result = buffer.toString();
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}
