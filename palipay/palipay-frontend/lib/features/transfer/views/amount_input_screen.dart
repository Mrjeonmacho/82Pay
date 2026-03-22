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

  bool _getIsInsufficient(WalletProvider provider) =>
      _enteredAmount > 0 && _enteredAmount > _getWalletBalanceValue(provider);

  bool _getCanProceed(WalletProvider provider) =>
      _enteredAmount > 0 && _enteredAmount <= _getWalletBalanceValue(provider);

  void _onNext() {
    final provider = context.read<WalletProvider>();
    if (!_getCanProceed(provider)) return;

    /// -----------------------------------------
    /// 지금: 다음 화면 이동만 처리
    /// -----------------------------------------
    // TODO: 다음 송금 확인 화면으로 이동

    /// -----------------------------------------
    /// 나중에 서버 연결 시 여기에서 실제 amount로 다시 검증 가능
    /// 예:
    /// context.read<WalletProvider>().loadWalletBalance(
    ///   accessToken: '실제 토큰',
    ///   walletId: 1,  //실제 아이디
    ///   amount: _enteredAmount,
    /// );
    /// -----------------------------------------
    ///
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransferConfirmView(
          bankName: widget.bankName,
          accountNumber: widget.accountNumber,
          // recipientName: widget.recipientName,
          recipientName: "홍길동",
          amount: _enteredAmount, // int 타입 금액
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().loadWalletBalance(
        accessToken: null, // 지금은 더미라 필요 없음
        walletId: 1, // 지금은 더미 wallet id
        amount: 0, // 초기 진입 시 잔액만 조회
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
    // 이 한 줄이 범인을 잡아줄 겁니다!
    print(
      "입력액: $_enteredAmount, 잔액: ${_getWalletBalanceValue(walletProvider)}, 로딩중: ${walletProvider.isLoading}, 진행가능: ${_getCanProceed(walletProvider)}",
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      appBar: PaliTopBar(
        title: 'transfer.title'.tr(),
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
              Text(
                'amount_input.from_my_wallet'.tr(),
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.abledFont,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                walletProvider.isLoading
                    ? 'transfer.amount.balance_loading'.tr()
                    : 'transfer.amount.balance_value'.tr(namedArgs: {'balance': _getFormattedWalletBalance(walletProvider)}),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.exampleFont,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 26),
              Text(
                'amount_input.to_bank'.tr(namedArgs: {'bankName': widget.bankName}),
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.abledFont,
                  fontWeight: FontWeight.bold,
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
                'amount_input.amount'.tr(),
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
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'amount_input.enter_in_krw'.tr(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.exampleFont,
                ),
              ),
              const SizedBox(height: 8),
              if (_getIsInsufficient(walletProvider))
                Text(
                  'amount_input.withdrawable_amount'.tr(namedArgs: {'balance': _getFormattedWalletBalance(walletProvider)}),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.warningRed,
                  ),
                ),
              const Spacer(),
              PaliButton(
                text: 'transfer.btn_next'.tr(),
                onPressed: _getCanProceed(walletProvider) && !walletProvider.isLoading
                    ? _onNext
                    : null,
                backgroundColor: AppColors.mainBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
