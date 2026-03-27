import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palipay_app/features/transfer/views/transfer_confirm_view.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/currency_input_formatter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/pali_button.dart';
import '../../../core/widgets/pali_input_oneline_field.dart';
import '../../../core/widgets/pali_nav_bars.dart';
import '../../wallet/providers/wallet_provider.dart';

class AmountInputScreen extends StatefulWidget {
  final String bankName;
  final String bankCode; // 🚀 [추가] 서버 전송을 위한 은행 코드 (예: "081")
  final String accountNumber;
  final String recipientName;
  final int? walletBalance;

  const AmountInputScreen({
    super.key,
    required this.bankName,
    required this.bankCode, // 필수 파라미터 추가
    required this.accountNumber,
    this.recipientName = "Unknown",
    this.walletBalance,
  });

  @override
  State<AmountInputScreen> createState() => _AmountInputScreenState();
}

class _AmountInputScreenState extends State<AmountInputScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool _didTryExceedAmount = false;

  int get _enteredAmount {
    final raw = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.isEmpty) return 0;
    return int.tryParse(raw) ?? 0;
  }

  int _getWalletBalanceValue(WalletProvider provider) {
    return provider.balance ?? widget.walletBalance ?? 0;
  }

  String _getFormattedWalletBalance(WalletProvider provider) {
    return CurrencyInputFormatter.format(_getWalletBalanceValue(provider));
  }

  bool _getShowAmountWarning(WalletProvider provider) =>
      _didTryExceedAmount ||
      (_enteredAmount > 0 && _enteredAmount > _getWalletBalanceValue(provider));

  bool _getCanProceed(WalletProvider provider) =>
      _enteredAmount > 0 && _enteredAmount <= _getWalletBalanceValue(provider);

  double _clamp(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  void _handleAmountChanged(String _) {
    setState(() {
      _didTryExceedAmount = false;
    });
  }

  void _handleAmountExceeded() {
    if (!mounted) return;
    setState(() {
      _didTryExceedAmount = true;
    });
  }

  void _onNext() {
    final provider = context.read<WalletProvider>();
    if (!_getCanProceed(provider)) return;

    // 🚀 [수정] TransferConfirmView 호출 시 bankCode를 함께 넘겨줍니다.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransferConfirmView(
          bankName: widget.bankName,
          bankCode: widget.bankCode, // 🚀 추가된 부분
          accountNumber: widget.accountNumber,
          recipientName: widget.recipientName,
          amount: _enteredAmount,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().loadWalletBalance(amount: 0);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final walletBalance = _getWalletBalanceValue(walletProvider);

    final amountFormatters = <TextInputFormatter>[
      FilteringTextInputFormatter.digitsOnly,
      _MaxAmountBlockFormatter(
        maxAmount: walletBalance,
        onExceeded: _handleAmountExceeded,
      ),
      CurrencyInputFormatter(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final safeBottom = MediaQuery.of(context).padding.bottom;

        final horizontalPadding = _clamp(width * 0.06, 18, 24);
        final topPadding = _clamp(height * 0.035, 20, 28);
        final bottomPadding = safeBottom + _clamp(height * 0.025, 16, 28);

        final labelFontSize = _clamp(width * 0.042, 16, 18);
        final valueFontSize = _clamp(width * 0.038, 14, 16);
        final helperFontSize = _clamp(width * 0.034, 12, 14);

        return Scaffold(
          backgroundColor: const Color(0xFFF8F8FB),
          appBar: PaliTopBar(title: 'transfer.title'.tr()),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                topPadding,
                horizontalPadding,
                bottomPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. 내 지갑 정보
                  Text(
                    'amount_input.from_my_wallet'.tr(),
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.abledFont,
                      fontWeight: FontWeight.bold,
                      fontSize: labelFontSize,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    walletProvider.isLoading
                        ? 'transfer.amount.balance_loading'.tr()
                        : 'transfer.amount.balance_value'.tr(
                            namedArgs: {
                              'balance': _getFormattedWalletBalance(
                                walletProvider,
                              ),
                            },
                          ),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.exampleFont,
                      fontSize: valueFontSize,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 2. 받는 분 정보
                  Text(
                    'amount_input.to_bank'.tr(
                      namedArgs: {'bankName': widget.bankName},
                    ),
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.abledFont,
                      fontWeight: FontWeight.bold,
                      fontSize: labelFontSize,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.accountNumber,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.exampleFont,
                      fontSize: valueFontSize,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 3. 금액 입력 섹션
                  Text(
                    'amount_input.amount'.tr(),
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.abledFont,
                      fontWeight: FontWeight.bold,
                      fontSize: labelFontSize,
                    ),
                  ),
                  PaliInputOnelineField(
                    hintText: '₩ 0',
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    onChanged: _handleAmountChanged,
                    inputFormatters: amountFormatters,
                  ),
                  const SizedBox(height: 8),

                  // 4. 경고 및 가이드 문구
                  Text(
                    'amount_input.withdrawable_amount'.tr(
                      namedArgs: {
                        'balance': _getFormattedWalletBalance(walletProvider),
                      },
                    ),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _getShowAmountWarning(walletProvider)
                          ? AppColors.warningRed
                          : AppColors.exampleFont,
                      fontSize: helperFontSize,
                    ),
                  ),

                  // 🚀 [수정] Spacer 대신 고정된 간격 사용 (버튼 위치 조정)
                  const SizedBox(height: 48),

                  // 5. 다음 버튼
                  PaliButton(
                    text: 'transfer.btn_next'.tr(),
                    onPressed:
                        _getCanProceed(walletProvider) &&
                            !walletProvider.isLoading
                        ? _onNext
                        : null,
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

class _MaxAmountBlockFormatter extends TextInputFormatter {
  final int maxAmount;
  final VoidCallback? onExceeded;

  _MaxAmountBlockFormatter({required this.maxAmount, this.onExceeded});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.isEmpty) return newValue;
    final nextAmount = int.tryParse(raw) ?? 0;
    if (maxAmount > 0 && nextAmount > maxAmount) {
      onExceeded?.call();
      return oldValue;
    }
    return newValue;
  }
}
