import 'package:flutter/material.dart';
import 'package:palipay_app/features/pin/providers/pin_provider.dart';
import 'package:provider/provider.dart';
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
}

class PinScreen extends StatefulWidget {
  final PinMode mode;
  final String? firstPin; // Confirm 모드일 때 비교를 위한 첫 번째 입력값

  const PinScreen({super.key, required this.mode, this.firstPin});

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

  void _handleError({String? message}) {
    setState(() {
      _attemptCount++;
      // 메시지가 인자로 들어오면 그걸 쓰고, 없으면 기본 메시지를 씁니다.
      _errorMessage =
          message ?? "Incorrect PIN. Please try again ($_attemptCount/5)";
      _inputPin = ""; // 입력값 초기화
    });

    // 흔들기 애니메이션 실행!
    _shakeController.forward(from: 0.0);

    // 2초 뒤에 에러 메시지만 슬쩍 지워주기
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _errorMessage = null);
    });
  }

  /// 숫자 키패드 탭 시 로직
  void _onKeyTap(String value) {
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
    if (_inputPin.isNotEmpty) {
      setState(() {
        _inputPin = _inputPin.substring(0, _inputPin.length - 1);
      });
    }
  }

  /// PIN 입력 완료 시 모드별 처리 로직
  void _handleComplete() async {
    final pinProvider = context.read<PinProvider>();
    final walletId = 12345;

    switch (widget.mode) {
      case PinMode.create:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PinScreen(mode: PinMode.confirm, firstPin: _inputPin),
          ),
        );
        break;

      case PinMode.confirm:
        // 1. 첫 번째 입력값과 일치하는지 확인
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
            _handleError(message: "PIN registration failed. Please try again.");
          }
        } else {
          _handleError(message: 'PINs do not match. Please try again.');
        }
        break;

      case PinMode.auth:
        final isValid = await pinProvider.verifyPin(
          walletId,
          pinNumber: _inputPin,
        );

        if (mounted && isValid) {
          // [수정] 이동하지 말고, 결과값 true만 가지고 돌아갑니다.
          Navigator.pop(context, true);
        } else {
          _handleError();
        }
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
    // 모드에 따른 동적 타이틀/서브타이틀 설정
    String title = "Enter Your PIN";
    String subTitle = "To secure your payment";

    if (widget.mode == PinMode.create) {
      title = "Create Your PIN";
      subTitle = "Set a 6-digit payment PIN";
    } else if (widget.mode == PinMode.confirm) {
      title = "Confirm Your PIN";
      subTitle = "Please re-enter your PIN to confirm";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // 디자인 시안의 백 버튼과 타이틀 구현
        title: const Text(
          "+82Pay",
          style: TextStyle(
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
        child: Column(
          children: [
            const SizedBox(height: 60),
            // 상단 헤더 영역
            Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.mainBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subTitle,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 60),

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

            // 에러 메시지 영역
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: AppColors.warningRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const Spacer(),
            PaliKeypad(
              onNumberTap: _onKeyTap, // 숫자 누르면 실행할 함수 연결
              onBackspace: _onBackspace, // 지우기 누르면 실행할 함수 연결
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
      width: 14,
      height: 14,
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
}
