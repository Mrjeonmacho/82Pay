import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 🎨 Theme & Widgets
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/pali_keypad.dart';

// 🚀 Providers
import '../providers/account_provider.dart';

class BankPasswordView extends StatefulWidget {
  final String bankName;
  final Map<String, dynamic> partialData;

  const BankPasswordView({
    super.key,
    required this.bankName,
    required this.partialData,
  });

  @override
  State<BankPasswordView> createState() => _BankPasswordViewState();
}

class _BankPasswordViewState extends State<BankPasswordView> {
  String _inputPassword = '';
  bool _isLoading = false;

  void _onKeyTap(String value) {
    if (_isLoading) return;
    if (_inputPassword.length < 4) {
      setState(() => _inputPassword += value);
      if (_inputPassword.length == 4) {
        _handleFinalLink();
      }
    }
  }

  void _onBackspace() {
    if (_isLoading) return;
    if (_inputPassword.isNotEmpty) {
      setState(() {
        _inputPassword = _inputPassword.substring(0, _inputPassword.length - 1);
      });
    }
  }

  /// 🚀 최종 계좌 연동 처리
  Future<void> _handleFinalLink() async {
    setState(() => _isLoading = true);

    try {
      final accountProvider = context.read<AccountProvider>();

      // 1. 요청 데이터 구성 (walletId 불필요 — 서버가 생성해서 응답으로 줌)
      final Map<String, dynamic> requestData = {
        ...widget.partialData,
        'accountPassword': _inputPassword,
      };

      // 2. 토큰 읽기 (소문자 키로 통일)
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'accesstoken') ?? '';

      // 3. API 호출 — 성공 시 accountProvider._linkedAccount에 walletId 자동 세팅
      final String result = await accountProvider.linkAccount(
        requestData: requestData,
        token: token,
      );

      if (!mounted) return;

      if (result == 'SUCCESS') {
        // walletId는 accountProvider.walletId로 바로 참조 가능
        debugPrint(
          '✅ [AccountLink] 연동 완료. walletId: ${accountProvider.walletId}',
        );

        _showSnackBar('bank.pwd.link_success'.tr(), Colors.green);
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        String errorMessage = 'bank.pwd.invalid_msg'.tr();
        if (result == 'SERVER_ERROR') errorMessage = 'common.server_error'.tr();
        if (result == 'TIMEOUT') errorMessage = 'common.timeout_error'.tr();
        if (result == 'ALREADY_LINKED')
          errorMessage = 'common.already_linked'.tr();

        setState(() {
          _isLoading = false;
          _inputPassword = '';
        });
        _showSnackBar(errorMessage, AppColors.warningRed);
      }
    } catch (e) {
      debugPrint('🚨 Final Link Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.mainBlue),
        title: Text(
          widget.bankName,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.mainBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 60),
          const Icon(
            Icons.lock_person_outlined,
            size: 80,
            color: AppColors.mainBlue,
          ),
          const SizedBox(height: 32),
          Text(
            'bank.pwd.title'.tr(),
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'bank.pwd.desc'.tr(),
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) => _buildDot(index)),
          ),
          if (_isLoading) ...[
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: AppColors.mainBlue),
          ],
          const Spacer(),
          PaliKeypad(onNumberTap: _onKeyTap, onBackspace: _onBackspace),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    bool isFilled = index < _inputPassword.length;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFilled ? AppColors.mainBlue : Colors.white,
        border: Border.all(
          color: isFilled ? AppColors.mainBlue : Colors.grey.shade300,
          width: 2,
        ),
      ),
    );
  }
}
