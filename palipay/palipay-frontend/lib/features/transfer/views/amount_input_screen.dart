import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palipay_app/core/providers/user_provider.dart';
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
  final String accountNumber;
  final String recipientName; // 추가
  final int? walletBalance;

  const AmountInputScreen({
    super.key,
    required this.bankName,
    required this.accountNumber,
    this.recipientName = "Unknown", // 추가
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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransferConfirmView(
          bankName: widget.bankName,
          accountNumber: widget.accountNumber,
          recipientName: widget.recipientName,
          amount: _enteredAmount, // int 타입 금액
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 1. UserProvider에서 현재 로그인된 유저의 정보와 토큰을 가져옵니다.
      final userProvider = context.read<UserProvider>();

      // UserProvider의 walletId가 String이라면 int로 변환해줍니다.
      final int wId = int.tryParse(userProvider.walletId ?? '0') ?? 0;

      // 2. 가져온 실제 정보를 바탕으로 잔액 조회를 요청합니다.
      context.read<WalletProvider>().loadWalletBalance(
        walletId: wId,
        amount: 0, // 초기 진입 시에는 현재 잔액만 가져옵니다.
      );
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
        final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

        final horizontalPadding = _clamp(width * 0.06, 18, 24);
        final topPadding = _clamp(height * 0.035, 20, 28);
        final bottomPadding =
            safeBottom + keyboardInset + _clamp(height * 0.025, 16, 28);

        final sectionGap = _clamp(height * 0.035, 20, 26);
        final labelToValueGap = _clamp(height * 0.008, 6, 8);
        final blockGap = _clamp(height * 0.03, 22, 30);
        final helperGap = _clamp(height * 0.01, 6, 8);

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
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  // [수정] 최소 높이 확보해서 버튼이 너무 위로 뜨지 않게 함
                  minHeight:
                      constraints.maxHeight -
                      topPadding -
                      MediaQuery.of(context).padding.top,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'amount_input.from_my_wallet'.tr(),
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.abledFont,
                          fontWeight: FontWeight.bold,
                          fontSize: labelFontSize,
                        ),
                      ),
                      SizedBox(height: labelToValueGap),
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
                          fontWeight: FontWeight.normal,
                          fontSize: valueFontSize,
                        ),
                      ),
                      SizedBox(height: blockGap),
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
                      SizedBox(height: labelToValueGap),
                      Text(
                        widget.accountNumber,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.exampleFont,
                          fontWeight: FontWeight.normal,
                          fontSize: valueFontSize,
                        ),
                      ),
                      SizedBox(height: blockGap),
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
                      SizedBox(height: helperGap),
                      Text(
                        'amount_input.enter_in_krw'.tr(),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.exampleFont,
                          fontSize: helperFontSize,
                        ),
                      ),
                      SizedBox(height: helperGap),
                      Text(
                        'amount_input.withdrawable_amount'.tr(
                          namedArgs: {
                            'balance': _getFormattedWalletBalance(
                              walletProvider,
                            ),
                          },
                        ),
                        style: AppTextStyles.bodyMedium.copyWith(
                          // 🔥 핵심: 초과하면 빨간색, 아니면 회색
                          color: _getShowAmountWarning(walletProvider)
                              ? AppColors.warningRed
                              : AppColors.exampleFont,
                          fontSize: helperFontSize,
                        ),
                      ),
                      const Spacer(),
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
