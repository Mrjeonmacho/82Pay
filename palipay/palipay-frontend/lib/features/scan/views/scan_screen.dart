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

    // [수정] 촬영 중 중복 클릭 방지용
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
        ( camera ) => camera.lensDirection == CameraLensDirection.back,
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

  Rect _getGuideRect(Size size) {
    final width = size.width;
    final height = size.height;

    final guideWidth = width * 0.76;
    final guideHeight = height * 0.34;
    final left = (width - guideWidth) / 2;
    final top = height * 0.24;

    return Rect.fromLTWH(left, top, guideWidth, guideHeight);
  }

  Future<void> _pickFromGallery() async {
    // [수정] ScanProvider는 이제 상위(main.dart)에서 주입받도록 변경
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
          pageBuilder: (_, __, ___) => GalleryCropScreen(imageFile: selectedFile),
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
      await croppedFile.writeAsBytes(
        img.encodeJpg(cropped, quality: 95),
      );

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
        pageBuilder: (_, __, ___) => ScanLoadingScreen(
          imageFile: imageFile,
          ),
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
      debugPrint('플래시 변경 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // [수정] build 안에서 ChangeNotifierProvider 만들지 않음
    // -> 상위(main.dart)에서 이미 제공받는 구조로 변경
    return Consumer<ScanProvider>(
      builder: (context, provider, _) {
        final isDisabled = provider.isBusy || _isTakingPicture || _isPickingFromGallery;

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

              _ScanOverlay(getGuideRect: _getGuideRect),

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
              child: CustomPaint(
                painter: _OverlayPainter(rect: rect,),
              ),
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
          child: Icon(icon, color: AppColors.logo, size: 24),
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