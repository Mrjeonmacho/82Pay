import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/pali_button.dart';
import '../../../core/widgets/pali_input_oneline_field.dart';
import '../../../core/widgets/pali_nav_bars.dart';
import '../../../core/widgets/pali_bank_selection_sheet.dart';
import 'amount_input_screen.dart';

class AccountInputScreen extends StatefulWidget {
  final String? initialBankName;
  final String? initialAccountNumber;
  final bool scanFailed;

  const AccountInputScreen({
    super.key,
    this.initialBankName,
    this.initialAccountNumber,
    this.scanFailed = false,
  });

  @override
  State<AccountInputScreen> createState() => _AccountInputScreenState();
}

class _AccountInputScreenState extends State<AccountInputScreen> {
  late final TextEditingController _accountController;
  late final TextEditingController _bankController;

  final List<String> _banks = const [
    'KB 국민',
    'IBK 기업',
    'NH 농협',
    '신한',
    '우리',
    '하나',
  ];

  bool get _canProceed =>
      _accountController.text.trim().isNotEmpty &&
      _bankController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _accountController = TextEditingController(
      text: widget.initialAccountNumber ?? '',
    );
    _bankController = TextEditingController(text: widget.initialBankName ?? '');
  }

  @override
  void dispose() {
    _accountController.dispose();
    _bankController.dispose();
    super.dispose();
  }

  Future<void> _showBankSheet() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BankSelectionSheet(
          countryCode: 'KR', // 한국 은행 고정
          onSelect: (selectedBank) {
            setState(() {
              _bankController.text = selectedBank['name'];
              // 추후 bankCode도 저장/전송할 수 있음: selectedBank['bankCode']
            });
          },
        );
      },
    );
  }

  void _onNext() {
    if (!_canProceed) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AmountInputScreen(
          bankName: _bankController.text.trim(),
          accountNumber: _accountController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      appBar: PaliTopBar(
        title: 'Transfer',
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.mainBlue,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.scanFailed) ...[
                Text(
                  'Scan failed. Please enter account information manually.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.warningRed,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              Text(
                'Account Number',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.abledFont,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              PaliInputOnelineField(
                hintText: 'Enter the account number',
                controller: _accountController,
                keyboardType: TextInputType.number,
                onChanged: (_) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 36),
              Text(
                'Bank',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.abledFont,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _showBankSheet,
                child: AbsorbPointer(
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      PaliInputOnelineField(
                        hintText: 'Select a bank',
                        controller: _bankController,
                        onChanged: (_) {},
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.exampleFont,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              PaliButton(
                text: 'Next',
                onPressed: _canProceed ? _onNext : null,
                backgroundColor: AppColors.mainBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
