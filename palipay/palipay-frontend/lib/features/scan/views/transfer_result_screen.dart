import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/pali_input_field.dart';
import '../../../core/widgets/pali_nav_bars.dart';

class TransferResultScreen extends StatefulWidget {
  final String bankName;
  final String accountNumber;
  final int walletBalance;

  const TransferResultScreen({
    super.key,
    required this.bankName,
    required this.accountNumber,
    this.walletBalance = 0, // 나중에 실제 값 주입
  });

  @override
  State<TransferResultScreen> createState() => _TransferResultScreenState();
}

class _TransferResultScreenState extends State<TransferResultScreen> {
  final TextEditingController _amountController = TextEditingController();

  int get _enteredAmount {
    final raw = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.isEmpty) return 0;
    return int.tryParse(raw) ?? 0;
  }

  bool get _isInsufficient =>
      _enteredAmount > 0 && _enteredAmount > widget.walletBalance;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'From My Wallet',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.abledFont,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Balance ₩ ${widget.walletBalance}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.exampleFont,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'To ${widget.bankName}',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.abledFont,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.accountNumber,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.exampleFont,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'How Send?',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.abledFont,
                ),
              ),
              const SizedBox(height: 10),
              PaliInputField(
                hintText: '₩ 0',
                controller: _amountController,
                keyboardType: TextInputType.number,
                onChanged: (_) {
                  setState(() {});
                },
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
                  'Withdrawable amount is ₩ ${widget.walletBalance}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.warningRed,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}