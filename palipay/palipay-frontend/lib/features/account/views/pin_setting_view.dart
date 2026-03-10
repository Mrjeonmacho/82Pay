import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../providers/account_provider.dart';

class PinSettingView extends StatefulWidget {
  final String walletId; // 이전 단계에서 전달받은 지갑 ID

  const PinSettingView({super.key, required this.walletId});

  @override
  State<PinSettingView> createState() => _PinSettingViewState();
}

class _PinSettingViewState extends State<PinSettingView> {
  final _pinController = TextEditingController();
  bool _isConfirmStep = false; // 1단계(생성) vs 3단계(확인) 구분
  String _firstPin = ""; // 처음 입력한 PIN 저장
  bool _isSuccess = false; // 5단계(성공) 화면 전환용

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  // PIN 입력 완료 시 호출되는 로직
  Future<void> _handlePinComplete(String value) async {
    if (!_isConfirmStep) {
      // 1단계: 첫 번째 PIN 입력 완료
      setState(() {
        _firstPin = value;
        _isConfirmStep = true;
        _pinController.clear(); // 확인을 위해 입력창 초기화
      });
    } else {
      // 3단계: 두 번째 PIN 입력 완료
      if (_firstPin == value) {
        await _registerPin(value);
      } else {
        // 불일치 시 처리
        _showErrorSnackBar('PINs do not match. Please try again.');
        setState(() {
          _isConfirmStep = false;
          _pinController.clear();
        });
      }
    }
  }

  // [USER_ACCOUNT_003] 서버에 PIN 등록
  Future<void> _registerPin(String pin) async {
    final accountProvider = context.read<AccountProvider>();

    // TODO: AuthProvider 등에서 실제 토큰을 가져와야 함
    const String tempToken = "USER_ACCESS_TOKEN";

    final success = await accountProvider.createPin(
      walletId: widget.walletId,
      pinNumber: pin,
      token: tempToken,
    );

    if (!mounted) return;

    if (success) {
      setState(() => _isSuccess = true); // 5번 성공 화면으로 전환
    } else {
      _showErrorSnackBar('Failed to set PIN. Please try again later.');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) return _buildSuccessUI(); // 5번 화면

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PaliTopBar(title: _isConfirmStep ? 'Confirm PIN' : 'Set PIN'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // 1 & 3단계 메시지
              Text(
                _isConfirmStep
                    ? 'Please re-enter your PIN'
                    : 'Create your 6-digit PIN',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // 2 & 4단계 입력창
              PaliInputField(
                controller: _pinController,
                hintText: '● ● ● ● ● ●',
                isPassword: true,
                maxLength: 6,
                keyboardType: TextInputType.number,
              ),
              const Spacer(),
              if (context.watch<AccountProvider>().isLoading)
                const CircularProgressIndicator(color: AppColors.mainBlue),
            ],
          ),
        ),
      ),
    );
  }

  // 5단계: 성공 화면 위젯
  Widget _buildSuccessUI() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              size: 100,
              color: AppColors.mainBlue,
            ),
            const SizedBox(height: 24),
            Text('PIN Set Successfully!', style: AppTextStyles.titleMedium),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: PaliButton(
                backgroundColor: AppColors.mainBlue,
                text: 'Next',
                onPressed: () {
                  // 다음 단계인 은행 선택 화면으로 이동
                  Navigator.pushNamed(context, '/bank-selection');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
