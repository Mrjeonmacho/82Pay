import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palipay_app/features/transfer/providers/transfer_provider.dart';
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
  final int? walletBalance;

  const AmountInputScreen({
    super.key,
    required this.bankName,
    required this.bankCode, // 필수 파라미터 추가
    required this.accountNumber,
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

  bool _getCanProceed(
    WalletProvider walletprovider,
    TransferProvider transferProvider,
  ) {
    return _enteredAmount > 0 &&
        _enteredAmount <= _getWalletBalanceValue(walletprovider);
  }

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
    final walletProvider = context.read<WalletProvider>();
    final transferProvider = context.read<TransferProvider>();

    if (!_getCanProceed(walletProvider, transferProvider)) return;

    // 🚀 [수정] TransferConfirmView 호출 시 bankCode를 함께 넘겨줍니다.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransferConfirmView(
          bankName: widget.bankName,
          bankCode: widget.bankCode, // 🚀 추가된 부분
          accountNumber: widget.accountNumber,
          recipientName: transferProvider.recipientName ?? 'store',
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
    context.read<TransferProvider>().startRecipientValidation(
      otherBankCode: widget.bankCode,
      otherAccountNumber: widget.accountNumber,
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final transferProvider = context.watch<TransferProvider>();
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
                  // 👉 1줄: To + 예금주 (or 스피너)
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // 텍스트와 스피너 높이 맞춤
                    children: [
                      Text(
                        'To ',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.abledFont,
                          fontWeight: FontWeight.bold,
                          fontSize: labelFontSize,
                        ),
                      ),

                      // 🚀 상태에 따른 대응
                      if (transferProvider.isRecipientLoading) ...[
                        // 1. 로딩 중: 화면을 막지 않고 텍스트 옆에 작은 스피너만 노출
                        const SizedBox(width: 8),
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.mainBlue,
                          ),
                        ),
                      ] else if (transferProvider.isRecipientValidated &&
                          (transferProvider.recipientName ?? '')
                              .isNotEmpty) ...[
                        // 2. 성공: 검증이 완료되었고 이름이 있을 때
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            transferProvider.recipientName!,
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.abledFont,
                              fontWeight: FontWeight.bold,
                              fontSize: labelFontSize,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ] else ...[
                        // 3. 실패 또는 초기 상태: 에러 메시지가 있거나 이름이 없을 때
                        const SizedBox(width: 4),
                        Text(
                          transferProvider.errorMessage ??
                              'amount_input.unknown'.tr(),
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.warningRed,
                            fontWeight: FontWeight.bold,
                            fontSize: labelFontSize,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 👉 2줄: 은행명 + 계좌번호
                  Text(
                    '${widget.bankName}  ${widget.accountNumber}',
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
                        _getCanProceed(walletProvider, transferProvider) &&
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
