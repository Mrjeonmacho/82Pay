import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/pali_nav_bars.dart';
import '../providers/scan_provider.dart';
import 'account_input_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _cameraController;
  final ImagePicker _picker = ImagePicker();

  bool _isCameraReady = false;
  final bool _isRearCamera = true;

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

      _cameraController = CameraController(
        selected,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();

      if (!mounted) return;
      setState(() {
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
    final provider = context.read<ScanProvider>();

    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );

    if (picked == null) return;

    await _handleImage(File(picked.path), provider);
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    final provider = context.read<ScanProvider>();

    try {
      final captured = await _cameraController!.takePicture();
      await _handleImage(File(captured.path), provider);
    } catch (e) {
      // 필요하면 스낵바 처리
    }
  }

  Future<void> _handleImage(File imageFile, ScanProvider provider) async {
    await provider.processImage(imageFile);

    if (!mounted) return;

    final result = provider.result;
    if (result == null) return;

    if (result.success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AccountInputScreen(
            initialBankName: result.bankName,
            initialAccountNumber: result.accountNumber,
            scanFailed: false,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AccountInputScreen(scanFailed: true),
        ),
      );
    }

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
    return ChangeNotifierProvider(
      create: (_) => ScanProvider(),
      child: Consumer<ScanProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: PaliTopBar(
              title: 'Scan',
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
                IconButton(
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
                        'Align account number within the frame',
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
                            provider.isBusy ? 'Scanning...' : 'Ready to scan',
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
                            ? 'Recognizing account information'
                            : 'Keep your device steady',
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

                if (provider.isBusy)
                  Positioned.fill(
                    child: Container(color: Colors.black.withOpacity(0.18)),
                  ),
              ],
            ),
          );
        },
      ),
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
    const double corner = 34;
    const double thickness = 4;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          _corner(top: true, left: true, corner: corner, thickness: thickness),
          _corner(top: true, left: false, corner: corner, thickness: thickness),
          _corner(top: false, left: true, corner: corner, thickness: thickness),
          _corner(
            top: false,
            left: false,
            corner: corner,
            thickness: thickness,
          ),
        ],
      ),
    );
  }

  Widget _corner({
    required bool top,
    required bool left,
    required double corner,
    required double thickness,
  }) {
    return Positioned(
      top: top ? 0 : null,
      bottom: top ? null : 0,
      left: left ? 0 : null,
      right: left ? null : 0,
      child: Container(
        width: corner,
        height: corner,
        decoration: BoxDecoration(
          border: Border(
            top: top
                ? BorderSide(color: AppColors.warningRed, width: thickness)
                : BorderSide.none,
            bottom: !top
                ? BorderSide(color: AppColors.warningRed, width: thickness)
                : BorderSide.none,
            left: left
                ? BorderSide(color: AppColors.thirdBlue, width: thickness)
                : BorderSide.none,
            right: !left
                ? BorderSide(color: AppColors.thirdBlue, width: thickness)
                : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: top && left ? const Radius.circular(18) : Radius.zero,
            topRight: top && !left ? const Radius.circular(18) : Radius.zero,
            bottomLeft: !top && left ? const Radius.circular(18) : Radius.zero,
            bottomRight: !top && !left
                ? const Radius.circular(18)
                : Radius.zero,
          ),
        ),
      ),
    );
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
    );
  }
}
