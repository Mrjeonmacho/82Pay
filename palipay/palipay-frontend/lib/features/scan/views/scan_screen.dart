import 'dart:io';

import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/pali_nav_bars.dart';
import '../providers/scan_provider.dart';
import '../../transfer/views/account_input_screen.dart';
import 'scan_loading_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _cameraController;
  final ImagePicker _picker = ImagePicker();

  bool _isCameraReady = false;
  // [수정] final 제거 -> 추후 카메라 전환 가능성도 열어두고,
  // 현재도 firstWhere 로직과 구조를 자연스럽게 맞추기 위해 bool로 유지
  bool _isRearCamera = true;
    // [수정] 촬영 중 중복 클릭 방지용
  bool _isTakingPicture = false;

  @override
  void initState() {
    super.initState();

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();

      final selected = cameras.firstWhere(
        (camera) => _isRearCamera
            ? camera.lensDirection == CameraLensDirection.back
            : camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        selected,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      // [수정] 기존 controller 먼저 정리 후 새 controller 할당
      await _cameraController?.dispose();

      setState(() {
        _cameraController = controller;
        _isCameraReady = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCameraReady = false;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    // [수정] ScanProvider는 이제 상위(main.dart)에서 주입받도록 변경
    final provider = context.read<ScanProvider>();

        try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (picked == null) return;

      await _handleImage(File(picked.path), provider);
    } catch (e) {
      // 필요시 스낵바 추가 가능
    }
  }

  Future<void> _takePicture() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isTakingPicture) {
      return;
    }

    final provider = context.read<ScanProvider>();

    try {
      setState(() {
        _isTakingPicture = true;
      });

      final captured = await _cameraController!.takePicture();
      await _handleImage(File(captured.path), provider);
    } catch (e) {
      // 필요하면 스낵바 처리
    } finally {
      if (!mounted) return;
      setState(() {
        _isTakingPicture = false;
      });
    }
  }

  Future<void> _handleImage(File imageFile, ScanProvider provider) async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ScanLoadingScreen(imageFile: imageFile),
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );

    provider.reset();
  }

  Future<void> _toggleFlash() async {
    final provider = context.read<ScanProvider>();

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      if (provider.flashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
      } else {
        await _cameraController!.setFlashMode(FlashMode.torch);
      }

      provider.toggleFlash();
    } catch (e) {
      // 웹/에뮬레이터/일부 기기에서 flash 지원 안 할 수 있음
    }
  }

  @override
  Widget build(BuildContext context) {
    // [수정] build 안에서 ChangeNotifierProvider 만들지 않음
    // -> 상위(main.dart)에서 이미 제공받는 구조로 변경
    return Consumer<ScanProvider>(
      builder: (context, provider, _) {
        final isDisabled = provider.isBusy || _isTakingPicture;

          return Scaffold(
            backgroundColor: Colors.black,
            appBar: PaliTopBar(
              title: 'common.scan'.tr(),
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.mainBlue,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    iconSize: 28,
                    splashRadius: 24,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AccountInputScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.mainBlue,
                    ),
                  ),
                ),
              ],
            ),
            body: Stack(
              children: [
                Positioned.fill(
                  child: _isCameraReady && _cameraController != null
                      ? CameraPreview(_cameraController!)
                      : Container(
                          color: Colors.black,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        ),
                ),

                const _ScanOverlay(),

                Positioned(
                  top: 36,
                  left: 24,
                  right: 24,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.56),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'scan.align_account_number'.tr(),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: 138,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: provider.isBusy
                                  ? AppColors.warningRed
                                  : Colors.white70,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            provider.isBusy ? 'scan.status_scanning'.tr() : 'scan.status_ready'.tr(),
                            style: AppTextStyles.headlineLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        provider.isBusy
                            ? 'scan.desc_recognizing'.tr()
                            : 'scan.desc_steady'.tr(),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 42,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _RoundActionButton(
                        icon: Icons.photo_library_outlined,
                        onTap: provider.isBusy ? null : _pickFromGallery,
                      ),
                      _CaptureButton(
                        onTap: provider.isBusy ? null : _takePicture,
                      ),
                      _RoundActionButton(
                        icon: provider.flashOn
                            ? Icons.flash_on_rounded
                            : Icons.flash_off_rounded,
                        onTap: provider.isBusy ? null : _toggleFlash,
                      ),
                    ],
                  ),
                ),

                if (provider.isBusy || _isTakingPicture)
                  Positioned.fill(
                    child: Container(color: Colors.black.withOpacity(0.18)),
                  ),
              ],
            ),
          );
      },
    );
  }
}

class _ScanOverlay extends StatelessWidget {
  const _ScanOverlay();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        final guideWidth = width * 0.76;
        final guideHeight = height * 0.34;
        final left = (width - guideWidth) / 2;
        final top = height * 0.24;

        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _OverlayPainter(
                  rect: Rect.fromLTWH(left, top, guideWidth, guideHeight),
                ),
              ),
            ),
            Positioned(
              left: left,
              top: top,
              child: _GuideFrame(width: guideWidth, height: guideHeight),
            ),
          ],
        );
      },
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final Rect rect;

  _OverlayPainter({required this.rect});

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.36);
    final clearPaint = Paint()..blendMode = BlendMode.clear;
    final layerRect = Offset.zero & size;

    canvas.saveLayer(layerRect, Paint());
    canvas.drawRect(layerRect, overlayPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(28)),
      clearPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter oldDelegate) {
    return oldDelegate.rect != rect;
  }
}

class _GuideFrame extends StatelessWidget {
  final double width;
  final double height;

  const _GuideFrame({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _ScannerFramePainter(
        colorRed: AppColors.warningRed,
        colorBlue: AppColors.thirdBlue,
        borderRadius: 28, // 오버레이 컷아웃과 일치시킴
        strokeWidth: 4,
      ),
    );
  }
}

class _ScannerFramePainter extends CustomPainter {
  final Color colorRed;
  final Color colorBlue;
  final double borderRadius;
  final double strokeWidth;

  _ScannerFramePainter({
    required this.colorRed,
    required this.colorBlue,
    required this.borderRadius,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 코너 선의 총 길이를 조금 더 길게(예: 40) 잡으면 더 네이버페이 같습니다.
    final double len = 40.0; 
    final double rad = borderRadius;

    final paintRed = Paint()
      ..color = colorRed
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final paintBlue = Paint()
      ..color = colorBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // 1. 좌상단 (Vertical: Blue, Curve: Blue, Horizontal: Red)
    canvas.drawPath(
      Path()
        ..moveTo(0, len)
        ..lineTo(0, rad)
        ..arcToPoint(Offset(rad, 0), radius: Radius.circular(rad), clockwise: true),
      paintBlue,
    );
    canvas.drawLine(Offset(rad, 0), Offset(len, 0), paintRed);

    // 2. 우상단 (Horizontal: Red, Curve: Red, Vertical: Blue)
    canvas.drawPath(
      Path()
        ..moveTo(size.width - len, 0)
        ..lineTo(size.width - rad, 0)
        ..arcToPoint(Offset(size.width, rad), radius: Radius.circular(rad), clockwise: true),
      paintRed,
    );
    canvas.drawLine(Offset(size.width, rad), Offset(size.width, len), paintBlue);

    // 3. 좌하단 (Vertical: Blue, Curve: Blue, Horizontal: Red)
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - len)
        ..lineTo(0, size.height - rad)
        ..arcToPoint(Offset(rad, size.height), radius: Radius.circular(rad), clockwise: false),
      paintBlue,
    );
    canvas.drawLine(Offset(rad, size.height), Offset(len, size.height), paintRed);

    // 4. 우하단 (Horizontal: Red, Curve: Red, Vertical: Blue)
    canvas.drawPath(
      Path()
        ..moveTo(size.width - len, size.height)
        ..lineTo(size.width - rad, size.height)
        ..arcToPoint(Offset(size.width, size.height - rad), radius: Radius.circular(rad), clockwise: false),
      paintRed,
    );
    canvas.drawLine(Offset(size.width, size.height - rad), Offset(size.width, size.height - len), paintBlue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoundActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _RoundActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(27),
      child: Opacity(
        opacity: onTap == null ? 0.45 : 1,
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.34),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

class _CaptureButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _CaptureButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.45 : 1,
        child: Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.logo,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
