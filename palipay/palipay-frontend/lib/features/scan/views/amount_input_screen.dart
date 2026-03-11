import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/currency_input_formatter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/pali_button.dart';
import '../../../core/widgets/pali_input_oneline_field.dart';
import '../../../core/widgets/pali_nav_bars.dart';

class AmountInputScreen extends StatefulWidget {
  final String bankName;
  final String accountNumber;
  final int walletBalance;

  const AmountInputScreen({
    super.key,
    required this.bankName,
    required this.accountNumber,
    this.walletBalance = 0,
  });

  @override
  State<AmountInputScreen> createState() => _AmountInputScreenState();
}

class _AmountInputScreenState extends State<AmountInputScreen> {
  final TextEditingController _amountController = TextEditingController();

  int get _enteredAmount {
    final raw = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.isEmpty) return 0;
    return int.tryParse(raw) ?? 0;
  }

  bool get _isInsufficient =>
      _enteredAmount > 0 && _enteredAmount > widget.walletBalance;

  bool get _canProceed =>
      _enteredAmount > 0 && _enteredAmount <= widget.walletBalance;

  void _onNext() {
    if (!_canProceed) return;

    // TODO: 다음 송금 확인 화면으로 이동
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      appBar: PaliTopBar(
        title: 'Transfer',
        leading: IconButton(
          icon: Icon(
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
              Text(
                'From My Wallet',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.abledFont,
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Balance ₩ ${CurrencyInputFormatter.format(widget.walletBalance)}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.exampleFont,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 26),
              Text(
                'To ${widget.bankName}',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.abledFont,
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.accountNumber,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.exampleFont,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 26),
              Text(
                'Amount',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.abledFont,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 0),
              PaliInputOnelineField(
                hintText: '₩0',
                controller: _amountController,
                keyboardType: TextInputType.number,
                onChanged: (_) {
                  setState(() {});
                },
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyInputFormatter(),
                ]
              ),
              const SizedBox(height: 8),
              Text(
                'Please enter in Korean Won',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.exampleFont,
                ),
              ),
              const SizedBox(height: 8),
              if (_isInsufficient)
                Text(
                  'Withdrawable amount is ₩ ${CurrencyInputFormatter.format(widget.walletBalance)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.warningRed,
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