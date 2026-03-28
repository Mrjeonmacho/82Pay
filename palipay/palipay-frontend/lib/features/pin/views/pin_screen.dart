import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:palipay_app/features/pin/providers/pin_provider.dart';
import 'package:provider/provider.dart';
import '../../wallet/providers/wallet_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../account/views/account_management_view.dart';
// PaliTopBar, PaliButton 등 활용
import '../../../core/widgets/widgets.dart';

/// PIN 화면의 모드를 정의합니다.
enum PinMode {
  create, // 처음 PIN 생성
  confirm, // PIN 다시 입력 (재확인)
  auth, // 결제 전 PIN 인증 (palipay)
  change, // PIN 변경
}

/// [추가] Change PIN 내부 단계를 위한 enum
enum ChangePinStep { verifyCurrentPin, enterNewPin, confirmNewPin, completed }

class PinScreen extends StatefulWidget {
  final PinMode mode;
  final String? firstPin; // Confirm 모드일 때 비교를 위한 첫 번째 입력값
  final int? walletId; // [추가] create, change API에 사용할 walletId

  final Future<void> Function(BuildContext context, String pin)? onAuthSuccess;

  const PinScreen({
    super.key,
    required this.mode,
    this.firstPin,
    this.walletId,
    this.onAuthSuccess,
  });

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  String _inputPin = "";
  String? _errorMessage;
  bool _isLoading = false; // [추가] API 처리 중 입력 막기

  // [추가] Change PIN 전용 상태값
  ChangePinStep _changeStep = ChangePinStep.verifyCurrentPin;
  String _currentPin = "";
  String _newPin = "";

  @override
  void initState() {
    super.initState();
    // 1. 흔들기 애니메이션 설정 (0.5초 동안 4번 흔들림)
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
    ]).animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  String get _title {
    switch (widget.mode) {
      case PinMode.create:
        return 'pin.create.title_create'.tr();
      case PinMode.confirm:
        return 'pin.create.title_confirm'.tr();
      case PinMode.auth:
        return 'pin.create.title_enter'.tr();
      case PinMode.change:
        switch (_changeStep) {
          case ChangePinStep.verifyCurrentPin:
            return 'pin.change.title_verify_current'.tr();
          case ChangePinStep.enterNewPin:
            return 'pin.change.title_create_new'.tr();
          case ChangePinStep.confirmNewPin:
            return 'pin.change.title_confirm_new'.tr();
          case ChangePinStep.completed:
            return 'pin.change.title_completed'.tr();
        }
    }
  }

  /// [추가] 모드/단계별 subtitle
  String get _subTitle {
    switch (widget.mode) {
      case PinMode.create:
        return 'pin.create.desc_create'.tr();
      case PinMode.confirm:
        return 'pin.create.desc_confirm'.tr();
      case PinMode.auth:
        return 'pin.create.desc_enter'.tr();
      case PinMode.change:
        switch (_changeStep) {
          case ChangePinStep.verifyCurrentPin:
            return 'pin.change.desc_verify_current'.tr();
          case ChangePinStep.enterNewPin:
            return 'pin.change.desc_create_new'.tr();
          case ChangePinStep.confirmNewPin:
            return 'pin.change.desc_confirm_new'.tr();
          case ChangePinStep.completed:
            return 'pin.change.desc_completed'.tr();
        }
    }
  }

  int? _resolveWalletId() {
    final walletProvider = context.read<WalletProvider>();
    return widget.walletId ?? walletProvider.walletId;
  }

  /// [수정] 공통 에러 처리
  void _handleError({required String message, bool countAttempt = false}) {
    final pinProvider = context.read<PinProvider>();

    if (countAttempt) {
      pinProvider.recordFailedAttempt();
    }

    final isLocked = pinProvider.isPinLocked;
    final attemptCount = pinProvider.attemptCount;

    setState(() {
      if (isLocked) {
        _errorMessage = 'pin.locked_for'.tr(
          namedArgs: {'time': pinProvider.formattedLockTime},
        );
      } else if (countAttempt) {
        _errorMessage = 'pin.error_incorrect'.tr(
          namedArgs: {'count': '$attemptCount'},
        );
      } else {
        _errorMessage = message;
      }

      _inputPin = "";
      _isLoading = false;
    });

    _shakeController.forward(from: 0.0);

    if (!isLocked) {
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted || context.read<PinProvider>().isPinLocked) return;
        setState(() => _errorMessage = null);
      });
    }
  }

  /// 숫자 키패드 탭 시 로직
  void _onKeyTap(String value) {
    final pinProvider = context.read<PinProvider>();
    // [수정] 잠금 중에는 입력 차단
    if (_isLoading || pinProvider.isPinLocked) return;

    if (_inputPin.length < 6) {
      setState(() {
        _inputPin += value;
        _errorMessage = null; // 입력 중에는 에러 초기화
      });
      // 6자리가 가득 차면 자동으로 완료 로직 실행
      if (_inputPin.length == 6) {
        _handleComplete();
      }
    }
  }

  /// 백스페이스 탭 시 로직
  void _onBackspace() {
    final pinProvider = context.read<PinProvider>();

    if (_isLoading || pinProvider.isPinLocked) return;

    if (_inputPin.isNotEmpty) {
      setState(() {
        _inputPin = _inputPin.substring(0, _inputPin.length - 1);
      });
    }
  }

  /// PIN 입력 완료 시 모드별 처리 로직
  void _handleComplete() async {
    final pinProvider = context.read<PinProvider>();
    final walletId = _resolveWalletId();

    if (walletId == null) {
      _handleError(message: 'Wallet ID not found.');
      return;
    }

    switch (widget.mode) {
      case PinMode.create:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PinScreen(
              mode: PinMode.confirm,
              firstPin: _inputPin,
              walletId: walletId, // [추가] 다음 화면에도 walletId 전달
            ),
          ),
        );
        break;

      case PinMode.confirm:
        if ((widget.firstPin ?? '') == _inputPin) {
          setState(() => _isLoading = true);

          // [수정] Provider를 통해 실제로 PIN을 생성/등록합니다.
          final success = await pinProvider.createPin(
            walletId,
            pinNumber: widget.firstPin ?? _inputPin,
          );

          if (!mounted) return;

          setState(() => _isLoading = false);

          if (success) {
            // [기획 반영] 생성 성공 시 바로 계좌 관리 화면으로!
            // pushAndRemoveUntil을 써서 이전 PIN 입력 스택을 모두 비워줍니다.
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const AccountManagementView(),
              ),
              (route) => route.isFirst, // 홈 화면만 남기고 다 지움
            );
          } else {
            _handleError(
              message:
                  pinProvider.errorMessage ??
                  'pin.error_registration_failed'.tr(),
            );
          }
        } else {
          _handleError(message: 'pin.error_mismatch'.tr());
        }
        break;

      case PinMode.auth:
        if (pinProvider.isPinLocked) {
          setState(() {
            _inputPin = "";
            _isLoading = false;
            _errorMessage = 'pin.locked_for'.tr(
              namedArgs: {'time': pinProvider.formattedLockTime},
            );
          });
          return;
        }

        setState(() => _isLoading = true);

        final isValid = await pinProvider.verifyPin(
          walletId,
          pinNumber: _inputPin,
        );

        if (!mounted) return;

        if (isValid) {
          pinProvider.resetPinLockState();

          if (widget.onAuthSuccess != null) {
            await widget.onAuthSuccess!(context, _inputPin);
          } else {
            Navigator.pop(context, _inputPin);
          }
        } else {
          _handleError(
            message: pinProvider.errorMessage ?? 'pin.error_mismatch'.tr(),
            countAttempt: true,
          );
        }
        break;

      case PinMode.change:
        // [추가] Change PIN은 별도 메서드로 분리
        await _handleChangePinFlow(pinProvider, walletId);
        break;
    }
  }

  /// [추가] Change PIN 전용 처리 로직
  Future<void> _handleChangePinFlow(
    PinProvider pinProvider,
    int walletId,
  ) async {
    switch (_changeStep) {
      case ChangePinStep.verifyCurrentPin:
        if (pinProvider.isPinLocked) {
          setState(() {
            _inputPin = "";
            _isLoading = false;
            _errorMessage = 'pin.locked_for'.tr(
              namedArgs: {'time': pinProvider.formattedLockTime},
            );
          });
          return;
        }

        setState(() => _isLoading = true);

        final isValid = await pinProvider.verifyPin(
          walletId,
          pinNumber: _inputPin,
        );

        if (!mounted) return;

        if (isValid) {
          pinProvider.resetPinLockState();
          setState(() {
            _currentPin = _inputPin;
            _inputPin = "";
            _errorMessage = null;
            _isLoading = false;
            _changeStep = ChangePinStep.enterNewPin;
          });
        } else {
          _handleError(
            message:
                pinProvider.errorMessage ??
                'pin.change.error_invalid_current'.tr(),
            countAttempt: true,
          );
        }
        break;

      case ChangePinStep.enterNewPin:
        if (_inputPin == _currentPin) {
          _handleError(
            message:
                pinProvider.errorMessage ??
                'pin.change.error_same_as_current'.tr(),
          );
          return;
        }

        setState(() {
          _newPin = _inputPin;
          _inputPin = "";
          _errorMessage = null;
          _changeStep = ChangePinStep.confirmNewPin;
        });
        break;

      case ChangePinStep.confirmNewPin:
        if (_inputPin != _newPin) {
          _handleError(
            message:
                pinProvider.errorMessage ?? 'pin.change.error_mismatch'.tr(),
          );
          return;
        }

        setState(() => _isLoading = true);

        final isUpdated = await pinProvider.updatePin(
          walletId: walletId,
          oldPinNumber: _currentPin,
          newPinNumber: _newPin,
        );

        if (!mounted) return;

        if (isUpdated) {
          setState(() {
            _inputPin = "";
            _errorMessage = null;
            _isLoading = false;
            _changeStep = ChangePinStep.completed;
          });
        } else {
          _handleError(
            message: pinProvider.errorMessage ?? 'pin.change.error_failed'.tr(),
          );
        }
        break;

      case ChangePinStep.completed:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pinProvider = context.watch<PinProvider>();
    final isPinLocked = pinProvider.isPinLocked;

    final bool showCompletedView =
        widget.mode == PinMode.change && _changeStep == ChangePinStep.completed;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: showCompletedView
          ? null
          : AppBar(
              title: Text(
                'pin.logo_text'.tr(),
                style: const TextStyle(
                  color: AppColors.mainBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.white,
              leading: const BackButton(color: AppColors.mainBlue),
            ),
      body: SafeArea(
        child: showCompletedView
            ? _buildCompletedView()
            : LayoutBuilder(
                builder: (context, constraints) {
                  final height = constraints.maxHeight;
                  final width = constraints.maxWidth;

                  final topSpace = height * 0.055;
                  final titleGap = height * 0.025;
                  final dotGap = height * 0.05;
                  // [핵심] 작은 기기에서 키패드가 너무 아래로 눌리지 않게 보정
                  final bottomPadding = width < 360
                      ? MediaQuery.of(context).viewPadding.bottom + 8
                      : MediaQuery.of(context).viewPadding.bottom + 16;

                  // [핵심] 키패드 왼쪽 로고도 화면 따라 살짝 줄이기
                  final double keypadLogoWidth = width < 360
                      ? 28
                      : width < 420
                      ? 34
                      : 40;

                  return Column(
                    children: [
                      SizedBox(height: topSpace),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                        child: Column(
                          children: [
                            Text(
                              _title,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.headlineLarge.copyWith(
                                color: AppColors.mainBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: titleGap),
                            Text(
                              _subTitle,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.abledFont,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: dotGap),

                      AnimatedBuilder(
                        animation: _shakeAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(_shakeAnimation.value, 0),
                            child: child,
                          );
                        },
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: width * 0.035,
                          children: List.generate(
                            6,
                            (index) => _buildDot(index, width),
                          ),
                        ),
                      ),

                      SizedBox(height: height * 0.025),

                      if (_errorMessage != null)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.08,
                          ),
                          child: Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.warningRed,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: CircularProgressIndicator(),
                        ),

                      const Spacer(),

                      Padding(
                        padding: EdgeInsets.only(bottom: bottomPadding),
                        child: PaliKeypad(
                          onNumberTap: _onKeyTap,
                          onBackspace: _onBackspace,
                          enabled: !_isLoading && !isPinLocked,
                          leftButton: Image.asset(
                            'assets/images/logos/palilogo1.png',
                            width: keypadLogoWidth,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  /// 입력된 핀의 수에 따라 도트의 채워짐 상태를 그려주는 위젯
  Widget _buildDot(int index, double screenWidth) {
    bool isFilled = index < _inputPin.length;
    final double size = screenWidth < 360 ? 16 : 20;
    final double margin = screenWidth < 360 ? 4 : 6;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: margin),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // 입력되면 Main Blue로 채우고, 아니면 테두리만 표시
        color: isFilled ? AppColors.mainBlue : Colors.white,
        border: Border.all(
          color: isFilled ? AppColors.mainBlue : Colors.grey.shade300,
          width: 2,
        ),
      ),
    );
  }

  Widget _buildCompletedView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final screenWidth = constraints.maxWidth;

        final topSpacing = screenHeight * 0.08;
        final titleToLogoSpacing = screenHeight * 0.06;
        final logoToTextSpacing = screenHeight * 0.06;
        final bottomSpacing = MediaQuery.of(context).viewPadding.bottom + 16;

        final logoSize = screenWidth < 360 ? 110.0 : 140.0;
        final iconSize = screenWidth < 360 ? 56.0 : 72.0;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: topSpacing),

              Text(
                _title,
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.mainBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: titleToLogoSpacing),

              Center(
                child: Container(
                  width: logoSize,
                  height: logoSize,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF3FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: iconSize,
                    color: AppColors.mainBlue,
                  ),
                ),
              ),

              SizedBox(height: logoToTextSpacing),

              Text(
                _subTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.exampleFont,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),

              const Spacer(),

              PaliButton(
                text: 'common.done'.tr(),
                onPressed: () {
                  Navigator.pop(context, true);
                },
                type: PaliButtonType.primary,
                backgroundColor: AppColors.mainBlue,
              ),

              SizedBox(height: bottomSpacing),
            ],
          ),
        );
      },
    );
  }
}
