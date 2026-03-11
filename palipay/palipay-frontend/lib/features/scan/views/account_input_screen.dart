import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/pali_button.dart';
import '../../../core/widgets/pali_input_oneline_field.dart';
import '../../../core/widgets/pali_nav_bars.dart';
import '../providers/wallet_provider.dart';
import 'amount_input_screen.dart';

class AccountInputScreen extends StatefulWidget {
  const AccountInputScreen({super.key});

  @override
  State<AccountInputScreen> createState() => _AccountInputScreenState();
}

class _AccountInputScreenState extends State<AccountInputScreen> {
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

  @override
  void dispose() {
    _accountController.dispose();
    _bankController.dispose();
    super.dispose();
  }

Future<void> _showBankSheet() async {
  final selected = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.35),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 40),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.disabledBackground,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Select a bank',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.mainBlue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.disabledBackground,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              bank,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.abledFont,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

  if (selected != null) {
    _bankController.text = selected;
    setState(() {});
  }
}

  void _onNext() {
    if (!_canProceed) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => WalletProvider(),
          child: AmountInputScreen(
            bankName: _bankController.text.trim(),
            accountNumber: _accountController.text.trim(),
          ),
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
                'Account Number',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.abledFont,
                  fontWeight: FontWeight.bold
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
                  fontWeight: FontWeight.bold
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