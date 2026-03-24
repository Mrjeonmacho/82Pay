// lib/features/account/views/bank_password_view.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/pali_keypad.dart'; // 우리가 만든 부품
import '../providers/account_provider.dart';

class BankPasswordView extends StatefulWidget {
  final String bankName;
  final String bankCode;
  final String accountNumber;
  final String accountUsername;
  final String currency;

  const BankPasswordView({
    super.key,
    required this.bankName,
    required this.bankCode,
    required this.accountNumber,
    required this.accountUsername,
    required this.currency,
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

  // [핵심] 최종 계좌 연동 로직
  Future<void> _handleFinalLink() async {
    setState(() => _isLoading = true);

    final accountProvider = context.read<AccountProvider>();

    // [테스트용 하드코딩] 비밀번호가 '1111'인지 확인
    final bool isPasswordCorrect = (_inputPassword == "1111");

    if (mounted) {
      if (isPasswordCorrect) {
        // 3. 성공 시: Provider 상태를 '계좌 있음'으로 강제 업데이트
        // (테스트를 위해 linkAccount 내부 로직도 성공을 반환하게 되어있어야 합니다)
        final accountProvider = context.read<AccountProvider>();

        // 실제 API 호출 대신 성공했다는 '가짜' 호출
        await accountProvider.linkAccount(
          walletId: "12345",
          bankCode: widget.bankCode,
          bankName: widget.bankName,
          accountNumber: widget.accountNumber,
          accountUsername: widget.accountUsername,
          moneyCode: widget.currency,
          token: "MOCK_TOKEN",
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('bank_password.link_success_msg'.tr()),
              backgroundColor: AppColors.mainBlue,
            ),
          );
          // 홈 화면으로 돌아가기 (모든 스택 제거)
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      } else {
        // 4. 실패 시: 흔들기 효과나 에러 메시지
        setState(() {
          _isLoading = false;
          _inputPassword = ""; // 입력값 초기화
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('bank.pwd.invalid_msg'.tr()),
            backgroundColor: AppColors.warningRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // 앱 PIN과 다른 배경색
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.mainBlue),
        title: Text(
          widget.bankName,
          style: const TextStyle(color: AppColors.mainBlue),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          // 은행 로고 혹은 아이콘
          const Icon(
            Icons.lock_person_outlined,
            size: 64,
            color: AppColors.mainBlue,
          ),
          const SizedBox(height: 24),
          Text(
            'bank_password.enter_password_title'.tr(),
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text('bank_password.enter_password_desc'.tr()),
          const SizedBox(height: 48),

          // 4자리 도트 (6자리가 아님!)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) => _buildDot(index)),
          ),

          if (_isLoading) ...[
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: AppColors.mainBlue),
          ],

          const Spacer(),

          // [리팩토링의 힘] 부품만 가져다 쓰면 끝!
          PaliKeypad(
            onNumberTap: _onKeyTap,
            onBackspace: _onBackspace,
            // 왼쪽 버튼은 로고 대신 '지문'이나 '빈칸'으로 설정 가능
            leftButton: const Icon(
              Icons.fingerprint,
              color: Colors.grey,
              size: 32,
            ),
          ),
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
