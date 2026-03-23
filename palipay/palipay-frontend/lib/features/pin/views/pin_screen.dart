import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:palipay_app/features/pin/providers/pin_provider.dart';
import 'package:provider/provider.dart';
import '../../account/providers/account_provider.dart';
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
enum ChangePinStep {
  verifyCurrentPin,
  enterNewPin,
  confirmNewPin,
  completed,
}

class PinScreen extends StatefulWidget {
  final PinMode mode;
  final String? firstPin; // Confirm 모드일 때 비교를 위한 첫 번째 입력값
  final int? walletId; // [추가] create, change API에 사용할 walletId

  const PinScreen({super.key, required this.mode, this.firstPin, this.walletId,});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  String _inputPin = "";
  String? _errorMessage;
  int _attemptCount = 0; // 틀린 횟수 추적
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
    if (widget.mode == PinMode.create) {
      return "Create PIN";
    } else if (widget.mode == PinMode.confirm) {
      return "Confirm PIN";
    } else if (widget.mode == PinMode.auth) {
      return "Enter PIN";
    } else if (widget.mode == PinMode.change) {
      switch (_changeStep) {
        case ChangePinStep.verifyCurrentPin:
          return "Enter PIN";   
        case ChangePinStep.enterNewPin:
          return "New PIN";             
        case ChangePinStep.confirmNewPin:
          return "Confirm PIN";     
        case ChangePinStep.completed:
          return "PIN Updated";
      }
    }
    return "Enter PIN";
  }

  /// [추가] 모드/단계별 subtitle
  String get _subTitle {
    if (widget.mode == PinMode.create) {
      return "Enter a new 6-digit PIN";
    } else if (widget.mode == PinMode.confirm) {
      return "Re-enter your new PIN";
    } else if (widget.mode == PinMode.change) {
      switch (_changeStep) {
        case ChangePinStep.verifyCurrentPin:
          return "Enter your current PIN";
        case ChangePinStep.enterNewPin:
          return "Enter a new PIN";
        case ChangePinStep.confirmNewPin:
          return "Re-enter your new PIN";
        case ChangePinStep.completed:
          return "Your PIN has been updated";
      }
    }
    return "Enter your PIN";
  }

  /// [수정] 공통 에러 처리
  void _handleError({
    required String message,
    bool countAttempt = false,
  }) {
    final pinProvider = context.read<PinProvider>();

    if (countAttempt) {
      pinProvider.recordFailedAttempt();
    }

    final isLocked = pinProvider.isPinLocked;
    final attemptCount = pinProvider.attemptCount;

    setState(() {
      if (isLocked) {
        _errorMessage =
            "Too many failed attempts. Try again in ${pinProvider.formattedLockTime}.";
      } else if (countAttempt) {
        _errorMessage =
            "$message ($attemptCount/${PinProvider.maxPinAttempts})";
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

    // [수정] walletId를 Provider의 실제 계좌 정보나 widget에서 받도록 변경
    final accountProvider = context.read<AccountProvider>();
    final walletIdStr = accountProvider.linkedAccount?.walletId ?? "12345";
    final walletId = widget.walletId ?? int.tryParse(walletIdStr) ?? 12345;

    switch (widget.mode) {
      case PinMode.create:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PinScreen(
                  mode: PinMode.confirm,
                  firstPin: _inputPin,
                  walletId: walletId, // [추가] 다음 화면에도 walletId 전달
                ),
          ),
        );
        break;

      case PinMode.confirm:
        if (widget.firstPin == _inputPin) {
          // [수정] Provider를 통해 실제로 PIN을 생성/등록합니다.
          final success = await pinProvider.createPin(walletId);

          if (mounted && success) {
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
            _handleError(message: 'pin.error_registration_failed'.tr());
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
            _errorMessage =
                "Too many failed attempts. Try again in ${pinProvider.formattedLockTime}.";
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
          Navigator.pop(context, _inputPin);
        } else {
          _handleError(
            message: "Incorrect PIN. Please try again.",
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
            _errorMessage =
                "Too many failed attempts. Try again in ${pinProvider.formattedLockTime}.";
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
            message: "The current PIN is incorrect.",
            countAttempt: true,
          );
        }
        break;

      case ChangePinStep.enterNewPin:
        if (_inputPin == _currentPin) {
          _handleError(
            message: "Your new PIN must be different from the current PIN.",
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
            message: "The new PINs do not match. Please try again.",
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
            message: pinProvider.errorMessage ?? "Failed to change PIN.",
          );
        }
        break;

      case ChangePinStep.completed:
        break;
    }
  }

  /// TODO: 실제 서버 API 호출 로직을 구현하는 부분입니다.
  Future<void> _registerPin(String pin) async {
    // 여기에 PinService를 통해 API를 호출하는 로직이 들어갑니다.
    // 성공 시 성공 화면으로 이동, 실패 시 에러 처리
  }

  @override
  Widget build(BuildContext context) {
    final pinProvider = context.watch<PinProvider>();
    final isPinLocked = pinProvider.isPinLocked;

    // [수정] change 모드이면서 완료 단계면 완료 화면 표시
    final bool showCompletedView =
        widget.mode == PinMode.change &&
            _changeStep == ChangePinStep.completed;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: showCompletedView
          ? null
          : AppBar(
              // 디자인 시안의 백 버튼과 타이틀 구현
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
          : Column(
              children: [
                const SizedBox(height: 44),
                // 상단 헤더 영역
                Text(
                  _subTitle,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.abledFont,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 50),

                // [수정] 핀 도트가 흔들리도록 AnimatedBuilder로 감싸기
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnimation.value, 0), // X축으로만 흔들림
                      child: child,
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) => _buildDot(index)),
                  ),
                ),

                const SizedBox(height: 20),

                // 에러 메시지 영역
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.warningRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                
                // [추가] lock
                if (isPinLocked)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      "Locked for ${pinProvider.formattedLockTime}",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.warningRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                // [추가] 로딩은 에러 메시지 아래에만 작게 표시
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: CircularProgressIndicator(),
                  ),

                const Spacer(),
                PaliKeypad(
                  onNumberTap: _onKeyTap, // 숫자 누르면 실행할 함수 연결
                  onBackspace: _onBackspace, // 지우기 누르면 실행할 함수 연결
                  enabled: !_isLoading && !isPinLocked,
                  leftButton: Center(
                    // 하단 왼쪽 로고 배치
                    child: Image.asset(
                    'assets/images/logos/palilogo1.png',
                    width: 40,
                    ),
                  ),
                ),
                // 커스텀 숫자 키패드
                const SizedBox(height: 40),
              ],
        ),
      ),
    );
  }

  /// 입력된 핀의 수에 따라 도트의 채워짐 상태를 그려주는 위젯
  Widget _buildDot(int index) {
    bool isFilled = index < _inputPin.length;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      width: 20,
      height: 20,
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

      final topSpacing = screenHeight > 760 ? 70.0 : 50.0;
      final titleToLogoSpacing = screenHeight > 760 ? 50.0 : 40.0;
      final logoToTextSpacing = screenHeight > 760 ? 50.0 : 40.0;
      final bottomSpacing = screenHeight > 760 ? 24.0 : 16.0;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: topSpacing),

            // 1. title
            Text(
              _title,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.mainBlue,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: titleToLogoSpacing),

            // 2. 로고(체크 아이콘)
            Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF3FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 72,
                  color: AppColors.mainBlue,
                ),
              ),
            ),

            SizedBox(height: logoToTextSpacing),

            // 3. 문구
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

            // 4. 버튼
            PaliButton(
              text: "Done",
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
