import 'dart:io';

import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/pali_nav_bars.dart';
import '../providers/scan_provider.dart';
import '../../transfer/views/account_input_screen.dart';
import 'scan_loading_screen.dart';
import 'gallery_crop_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _cameraController;
  final ImagePicker _picker = ImagePicker();

  bool _isCameraReady = false;
  // 촬영 중 중복 클릭 방지용
  bool _isTakingPicture = false;
  bool _isPickingFromGallery = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();

      final selected = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
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

      // 기존 controller 먼저 정리 후 새 controller 할당
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
      debugPrint('카메라 초기화 실패: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  double _clamp(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  Rect _getGuideRect(Size size) {
    final width = size.width;
    final height = size.height;

    final guideWidth = _clamp(width * 0.76, 260, 420);
    final guideHeight = _clamp(height * 0.34, 150, 280);
    final left = (width - guideWidth) / 2;
    final top = _clamp(height * 0.24, 120, 250);

    return Rect.fromLTWH(left, top, guideWidth, guideHeight);
  }

  Future<void> _pickFromGallery() async {
    // ScanProvider는 상위(main.dart)에서 주입받도록 변경
    final provider = context.read<ScanProvider>();

    if (_isPickingFromGallery) return;

    try {
      setState(() {
        _isPickingFromGallery = true;
      });

      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (!mounted) return;

      if (picked == null) {
        setState(() {
          _isPickingFromGallery = false;
        });
        return;
      }

      final selectedFile = File(picked.path);

      final croppedFile = await Navigator.push<File>(
        context,
        PageRouteBuilder(
          opaque: true,
          pageBuilder: (_, __, ___) =>
              GalleryCropScreen(imageFile: selectedFile),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );

      if (!mounted) return;

      setState(() {
        _isPickingFromGallery = false;
      });

      if (croppedFile == null) return;

      await _handleImage(croppedFile, provider);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPickingFromGallery = false;
        });
      }
      debugPrint('갤러리 선택 실패: $e');
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
      final originalFile = File(captured.path);

      final screenSize = MediaQuery.of(context).size;
      final guideRect = _getGuideRect(screenSize);

      final croppedFile = await _cropImageByGuideWithPadding(
        imageFile: originalFile,
        guideRectOnScreen: guideRect,
        screenSize: screenSize,
        horizontalPaddingRatio: 0.10,
        verticalPaddingRatio: 0.20,
      );
      await _handleImage(croppedFile, provider);
    } catch (e) {
      debugPrint('촬영 실패: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _isTakingPicture = false;
      });
    }
  }

  Future<File> _cropImageByGuideWithPadding({
    required File imageFile,
    required Rect guideRectOnScreen,
    required Size screenSize,
    double horizontalPaddingRatio = 0.10,
    double verticalPaddingRatio = 0.20,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final decoded = img.decodeImage(bytes);

      if (decoded == null) {
        return imageFile;
      }

      img.Image normalized = decoded;

      final imageWidth = normalized.width.toDouble();
      final imageHeight = normalized.height.toDouble();

      final screenRatio = screenSize.width / screenSize.height;
      final imageRatio = imageWidth / imageHeight;

      double scale;
      double offsetX = 0;
      double offsetY = 0;

      // CameraPreview가 cover처럼 꽉 차게 보이는 기준
      if (imageRatio > screenRatio) {
        scale = screenSize.height / imageHeight;
        final drawnWidth = imageWidth * scale;
        offsetX = (drawnWidth - screenSize.width) / 2;
      } else {
        scale = screenSize.width / imageWidth;
        final drawnHeight = imageHeight * scale;
        offsetY = (drawnHeight - screenSize.height) / 2;
      }

      double cropLeft = (guideRectOnScreen.left + offsetX) / scale;
      double cropTop = (guideRectOnScreen.top + offsetY) / scale;
      double cropWidth = guideRectOnScreen.width / scale;
      double cropHeight = guideRectOnScreen.height / scale;

      final horizontalPadding = cropWidth * horizontalPaddingRatio;
      final verticalPadding = cropHeight * verticalPaddingRatio;

      cropLeft -= horizontalPadding;
      cropTop -= verticalPadding;
      cropWidth += horizontalPadding * 2;
      cropHeight += verticalPadding * 2;

      cropLeft = cropLeft.clamp(0, imageWidth - 1);
      cropTop = cropTop.clamp(0, imageHeight - 1);

      if (cropLeft + cropWidth > imageWidth) {
        cropWidth = imageWidth - cropLeft;
      }

      if (cropTop + cropHeight > imageHeight) {
        cropHeight = imageHeight - cropTop;
      }

      final cropped = img.copyCrop(
        normalized,
        x: cropLeft.round(),
        y: cropTop.round(),
        width: cropWidth.round(),
        height: cropHeight.round(),
      );

      final originalPath = imageFile.path;
      final dotIndex = originalPath.lastIndexOf('.');
      final croppedPath = dotIndex != -1
          ? '${originalPath.substring(0, dotIndex)}_cropped.jpg'
          : '${originalPath}_cropped.jpg';

      final croppedFile = File(croppedPath);
      await croppedFile.writeAsBytes(img.encodeJpg(cropped, quality: 95));

      return croppedFile;
    } catch (e) {
      debugPrint('크롭 실패: $e');
      return imageFile;
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
          return FadeTransition(opacity: animation, child: child);
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
      debugPrint('플래시 변경 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // build 안에서 ChangeNotifierProvider 만들지 않음
    // -> 상위(main.dart)에서 이미 제공받는 구조로 변경
    return Consumer<ScanProvider>(
      builder: (context, provider, _) {
        final isDisabled =
            provider.isBusy || _isTakingPicture || _isPickingFromGallery;

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            final safeBottom = MediaQuery.of(context).padding.bottom;

            final guideTextTop = _clamp(height * 0.045, 24, 40);
            final guideHorizontal = _clamp(width * 0.06, 18, 28);
            final guideInnerHorizontal = _clamp(width * 0.045, 14, 20);
            final guideInnerVertical = _clamp(height * 0.012, 8, 12);

            final roundButtonSize = _clamp(width * 0.14, 52, 58);
            final captureButtonSize = _clamp(width * 0.20, 74, 82);

            final guideRect = _getGuideRect(Size(width, height));
            final guideBottom = guideRect.bottom;

            final buttonsBottom = safeBottom + _clamp(height * 0.04, 24, 40);
            final buttonAreaTop = height - buttonsBottom - captureButtonSize;
            final statusTop =
                guideBottom + ((buttonAreaTop - guideBottom) * 0.10);

            final statusDotSize = _clamp(width * 0.025, 8, 10);
            final statusGap = _clamp(width * 0.025, 8, 10);

            return Scaffold(
              backgroundColor: Colors.black,
              appBar: PaliTopBar(
                title: 'common.scan'.tr(),
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

                  _ScanOverlay(getGuideRect: _getGuideRect),

                  Positioned(
                    top: guideTextTop,
                    left: guideHorizontal,
                    right: guideHorizontal,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: guideInnerHorizontal,
                          vertical: guideInnerVertical,
                        ),
                        child: Text(
                          'scan.align_account_number'.tr(),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.buttonFont,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: statusTop,
                    left: guideHorizontal,
                    right: guideHorizontal,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: statusDotSize,
                              height: statusDotSize,
                              decoration: BoxDecoration(
                                color: provider.isBusy
                                    ? AppColors.warningRed
                                    : Colors.white70,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: statusGap),
                            Text(
                              provider.isBusy
                                  ? 'scan.status_scanning'.tr()
                                  : 'scan.status_ready'.tr(),
                              style: AppTextStyles.headlineLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: _clamp(height * 0.01, 6, 10)),
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
                    bottom: buttonsBottom,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _RoundActionButton(
                          icon: Icons.photo_library_outlined,
                          onTap: provider.isBusy ? null : _pickFromGallery,
                          size: roundButtonSize,
                        ),
                        _CaptureButton(
                          onTap: provider.isBusy ? null : _takePicture,
                          size: captureButtonSize,
                        ),
                        _RoundActionButton(
                          icon: provider.flashOn
                              ? Icons.flash_on_rounded
                              : Icons.flash_off_rounded,
                          onTap: provider.isBusy ? null : _toggleFlash,
                          size: roundButtonSize,
                        ),
                      ],
                    ),
                  ),

                  if (isDisabled)
                    Positioned.fill(
                      child: Container(
                        color: _isPickingFromGallery
                            ? Colors.black
                            : Colors.black.withOpacity(0.18),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ScanOverlay extends StatelessWidget {
  final Rect Function(Size size) getGuideRect;

  const _ScanOverlay({required this.getGuideRect});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final rect = getGuideRect(
          Size(constraints.maxWidth, constraints.maxHeight),
        );

        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _OverlayPainter(rect: rect)),
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
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.7);
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

class _RoundActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;

  const _RoundActionButton({
    required this.icon,
    required this.onTap,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = (size * 0.44).clamp(22.0, 26.0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: Opacity(
        opacity: onTap == null ? 0.45 : 1,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.logo, size: iconSize),
        ),
      ),
    );
  }
}

class _CaptureButton extends StatelessWidget {
  final VoidCallback? onTap;
  final double size;

  const _CaptureButton({required this.onTap, required this.size});

  @override
  Widget build(BuildContext context) {
    final innerSize = size * 0.72;
    final cameraIconSize = (size * 0.36).clamp(24.0, 30.0);
    final borderWidth = (size * 0.05).clamp(3.5, 4.5);

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.45 : 1,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: borderWidth),
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
              width: innerSize,
              height: innerSize,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Icon(
                Icons.camera_alt_outlined,
                color: AppColors.logo,
                size: cameraIconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
