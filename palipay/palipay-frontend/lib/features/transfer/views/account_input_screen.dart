import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  String? _accountErrorText;
  String? _selectedBankCode;

  bool get _canProceed =>
      _accountController.text.trim().isNotEmpty &&
      _bankController.text.trim().isNotEmpty &&
      _selectedBankCode != null &&
      _accountController.text.trim().length <= 20;

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

  double _clamp(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  void _handleAccountChanged(String value) {
    setState(() {
      _accountErrorText = null;
    });
  }

  void _handleAccountLengthExceeded() {
    setState(() {
      _accountErrorText = 'account_input.error_max_length'.tr();
    });
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
              _bankController.text = selectedBank['name'] ?? '';
              // 🚀 [해결 포인트 3] 선택된 은행 코드를 변수에 저장합니다.
              _selectedBankCode = selectedBank['bankCode']?.toString();
            });
          },
        );
      },
    );
  }

  void _onNext() {
    final account = _accountController.text.trim();
    final bank = _bankController.text.trim();

    setState(() {
      if (account.isEmpty) {
        _accountErrorText = null;
      } else if (account.length > 20) {
        _accountErrorText = 'account_input.error_max_length'.tr();
      } else {
        _accountErrorText = null;
      }
    });

    if (account.isEmpty || bank.isEmpty || account.length > 20) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AmountInputScreen(
          bankName: bank,
          accountNumber: account,
          bankCode: _selectedBankCode!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final safeBottom = MediaQuery.of(context).padding.bottom;

        final horizontalPadding = _clamp(width * 0.06, 18, 24);
        final topPadding = _clamp(height * 0.035, 20, 28);
        final bottomPadding = safeBottom + _clamp(height * 0.025, 16, 28);

        final sectionGap = _clamp(height * 0.04, 24, 36);
        final labelToFieldGap = _clamp(height * 0.008, 6, 8);
        final warningGap = _clamp(height * 0.02, 12, 16);

        final labelFontSize = _clamp(width * 0.042, 16, 18);
        final warningFontSize = _clamp(width * 0.034, 12, 14);
        final arrowSize = _clamp(width * 0.065, 22, 26);

        return Scaffold(
          backgroundColor: const Color(0xFFF8F8FB),
          appBar: PaliTopBar(title: 'transfer.title'.tr()),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                topPadding,
                horizontalPadding,
                bottomPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.scanFailed) ...[
                    Text(
                      'account_input.scan_failed_msg'.tr(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.warningRed,
                        fontSize: warningFontSize,
                      ),
                    ),
                    SizedBox(height: warningGap),
                  ],

                  Text(
                    'account_input.account_number'.tr(),
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.abledFont,
                      fontWeight: FontWeight.bold,
                      fontSize: labelFontSize,
                    ),
                  ),
                  SizedBox(height: labelToFieldGap),
                  PaliInputOnelineField(
                    hintText: 'transfer.input.hint_account_number'.tr(),
                    controller: _accountController,
                    keyboardType: TextInputType.number,
                    maxLength: 20,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    errorText: _accountErrorText,
                    onChanged: _handleAccountChanged,
                    onMaxLengthExceeded: _handleAccountLengthExceeded,
                  ),
                  SizedBox(height: sectionGap),
                  Text(
                    'account_input.bank'.tr(),
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.abledFont,
                      fontWeight: FontWeight.bold,
                      fontSize: labelFontSize,
                    ),
                  ),
                  SizedBox(height: labelToFieldGap),
                  GestureDetector(
                    onTap: _showBankSheet,
                    child: AbsorbPointer(
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          PaliInputOnelineField(
                            hintText: 'transfer.input.hint_select_bank'.tr(),
                            controller: _bankController,
                            onChanged: (_) {},
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              right: _clamp(width * 0.01, 4, 8),
                            ),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.exampleFont,
                              size: arrowSize,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  PaliButton(
                    text: 'transfer.btn_next'.tr(),
                    onPressed: _canProceed ? _onNext : null,
                    backgroundColor: AppColors.mainBlue,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
