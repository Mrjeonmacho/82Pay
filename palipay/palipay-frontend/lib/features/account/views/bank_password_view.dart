// lib/features/account/views/bank_password_view.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart'; // 💡 Dio 임포트 확인!
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/pali_keypad.dart';
import '../providers/account_provider.dart';

// 💡 1. 클래스 정의가 정확해야 합니다.
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
  String _inputPassword = "";
  bool _isLoading = false;

  void _onKeyTap(String value) {
    if (_inputPassword.length < 4) {
      setState(() => _inputPassword += value);
      if (_inputPassword.length == 4) {
        _handleFinalLink();
      }
    }
  }

  void _onBackspace() {
    if (_inputPassword.isNotEmpty) {
      setState(
        () => _inputPassword = _inputPassword.substring(
          0,
          _inputPassword.length - 1,
        ),
      );
    }
  }

  Future<void> _handleFinalLink() async {
    setState(() => _isLoading = true);

    try {
      if (mounted) {
        final accountProvider = context.read<AccountProvider>();

        // 💡 2. 타입을 명시적으로 지정하여 'Map<dynamic, dynamic>' 에러 방지
        final Map<String, dynamic> requestData = {
          ...widget.partialData,
          'accountPassword': _inputPassword,
          'walletId': 0,
        };

        const storage = FlutterSecureStorage();
        final realToken = await storage.read(key: 'accessToken') ?? '';

        final String result = await accountProvider.linkAccount(
          requestData: requestData,
          token: realToken,
        );

        if (mounted) {
          if (result == "SUCCESS") {
            _showSnackBar('bank.pwd.link_success'.tr(), Colors.green);
            Navigator.popUntil(context, (route) => route.isFirst);
          } else {
            String errorMessage = 'bank.pwd.invalid_msg'.tr();
            if (result == "SERVER_ERROR") errorMessage = "서버 점검 중입니다.";
            if (result == "TIMEOUT") errorMessage = "서버 연결 시간이 초과되었습니다.";

            setState(() {
              _isLoading = false;
              _inputPassword = "";
            });
            _showSnackBar(errorMessage, AppColors.warningRed);
          }
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint("Final Link Error: $e");
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
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
          style: const TextStyle(
            color: AppColors.mainBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(
            Icons.lock_person_outlined,
            size: 64,
            color: AppColors.mainBlue,
          ),
          const SizedBox(height: 24),
          Text(
            'bank.pwd.title'.tr(),
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text('bank.pwd.desc'.tr()),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) => _buildDot(index)),
          ),
          if (_isLoading) ...[
            const SizedBox(height: 32),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFilled ? AppColors.mainBlue : Colors.white,
        border: Border.all(
          color: isFilled ? AppColors.mainBlue : Colors.grey.shade400,
          width: 2,
        ),
      ),
    );
  }
}
