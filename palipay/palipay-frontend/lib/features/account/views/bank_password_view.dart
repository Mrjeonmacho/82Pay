import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 🎨 Theme & Widgets
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/pali_keypad.dart';

// 🚀 Providers
import '../../../core/providers/user_provider.dart';
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
  String _inputPassword = "";
  bool _isLoading = false;

  /// 키패드 입력 로직
  void _onKeyTap(String value) {
    if (_isLoading) return; // 로딩 중 입력 방지
    if (_inputPassword.length < 4) {
      setState(() => _inputPassword += value);
      if (_inputPassword.length == 4) {
        _handleFinalLink();
      }
    }
  }

  /// 백스페이스 로직
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
      final userProvider = context.read<UserProvider>();

      // 1. 요청 데이터 구성
      final Map<String, dynamic> requestData = {
        ...widget.partialData,
        'accountPassword': _inputPassword,
        'walletId': 0, // 초기 연동 시 0 또는 서버 규격에 맞춤
      };

      // 2. 토큰 읽기
      const storage = FlutterSecureStorage();
      final realToken = await storage.read(key: 'accesstoken') ?? '';

      // 3. API 호출 (계좌 연동)
      final String result = await accountProvider.linkAccount(
        requestData: requestData,
        token: realToken,
      );

      if (!mounted) return;

      if (result == "SUCCESS") {
        // ✅ [성공] 스낵바 표시
        _showSnackBar('bank.pwd.link_success'.tr(), Colors.green);

        // 💡 [핵심] UserProvider의 정보를 업데이트 (walletId 포함)
        // 리팩토링된 setUserInfo 규격(token, context 필수)에 맞춤
        final newWalletId = accountProvider.walletId?.toString();

        await userProvider.setUserInfo(
          token: realToken,
          walletId: newWalletId,
          context: context, // 🌐 언어 상태 유지를 위해 context 전달
        );

        debugPrint('✅ [AccountLink] WalletId 동기화 완료: $newWalletId');

        // 메인 화면으로 돌아가기
        if (mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      } else {
        // ❌ [실패] 에러 핸들링
        String errorMessage = 'bank.pwd.invalid_msg'.tr();
        if (result == "SERVER_ERROR") errorMessage = "common.server_error".tr();
        if (result == "TIMEOUT") errorMessage = "common.timeout_error".tr();

        setState(() {
          _isLoading = false;
          _inputPassword = ""; // 비번 틀리면 초기화
        });
        _showSnackBar(errorMessage, AppColors.warningRed);
      }
    } catch (e) {
      debugPrint("🚨 Final Link Error: $e");
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

          // 비밀번호 도트 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) => _buildDot(index)),
          ),

          if (_isLoading) ...[
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: AppColors.mainBlue),
          ],

          const Spacer(),

          // 커스텀 키패드
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
