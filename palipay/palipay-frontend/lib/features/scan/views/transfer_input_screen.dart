import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/pali_button.dart';
import '../../../core/widgets/pali_input_field.dart';
import '../../../core/widgets/pali_nav_bars.dart';

class TransferInputScreen extends StatefulWidget {
  const TransferInputScreen({super.key});

  @override
  State<TransferInputScreen> createState() => _TransferInputScreenState();
}

class _TransferInputScreenState extends State<TransferInputScreen> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _bankController = TextEditingController();

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

  Future<void> _showBankSheet() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.disabledBackground,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Select a bank",
                style: AppTextStyles.headlineLarge,
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                itemCount: _banks.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 64,
                ),
                itemBuilder: (context, index) {
                  final bank = _banks[index];

                  return InkWell(
                    onTap: () => Navigator.pop(context, bank),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.disabledBackground,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          bank,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      _bankController.text = selected;
      setState(() {});
    }
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 안내 텍스트
              Text(
                "Enter account information",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.exampleFont,
                ),
              ),

              const SizedBox(height: 28),

              /// Account Number
              Text(
                "Account Number",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.abledFont,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              PaliInputField(
                hintText: "Enter the account number",
                controller: _accountController,
                keyboardType: TextInputType.number,
                maxLength: 20,
                onChanged: (_) {
                  setState(() {});
                },
              ),

              const SizedBox(height: 28),

              /// Bank
              Text(
                "Bank",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.abledFont,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              GestureDetector(
                onTap: _showBankSheet,
                child: AbsorbPointer(
                  child: TextField(
                    controller: _bankController,
                    style: AppTextStyles.bodyMedium,
                    decoration: InputDecoration(
                      hintText: "Select a bank",
                      hintStyle: const TextStyle(
                        color: AppColors.exampleFont,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.disabledBackground,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.mainBlue,
                          width: 2,
                        ),
                      ),
                      suffixIcon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.exampleFont,
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              /// Next Button
              PaliButton(
                text: "Next",
                onPressed: _canProceed ? () {} : null,
                backgroundColor: AppColors.mainBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}