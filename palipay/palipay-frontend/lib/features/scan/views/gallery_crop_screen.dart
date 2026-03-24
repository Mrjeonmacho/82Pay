import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:easy_localization/easy_localization.dart';
import 'package:palipay_app/core/theme/app_colors.dart';
import '../../../core/widgets/pali_nav_bars.dart';
import '../../../core/widgets/pali_button.dart';
import '../../../core/theme/app_text_styles.dart';

class GalleryCropScreen extends StatefulWidget {
  final File imageFile;

  const GalleryCropScreen({
    super.key,
    required this.imageFile,
  });

  @override
  State<GalleryCropScreen> createState() => _GalleryCropScreenState();
}

class _GalleryCropScreenState extends State<GalleryCropScreen> {
  final GlobalKey _imageAreaKey = GlobalKey();

  Rect _selectionRect = const Rect.fromLTWH(60, 180, 240, 100);

  Size? _displayedImageSize;
  double _displayedImageLeft = 0;
  double _displayedImageTop = 0;

  img.Image? _decodedImage;

  bool _isMoving = false;
  bool _isResizing = false;
  Offset? _lastFocalPoint;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final bytes = await widget.imageFile.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (!mounted) return;

    setState(() {
      _decodedImage = decoded;
    });
  }

  void _updateDisplayedImageRect(BoxConstraints constraints) {
    if (_decodedImage == null) return;

    final imageWidth = _decodedImage!.width.toDouble();
    final imageHeight = _decodedImage!.height.toDouble();

    final boxWidth = constraints.maxWidth;
    final boxHeight = constraints.maxHeight;

    final imageRatio = imageWidth / imageHeight;
    final boxRatio = boxWidth / boxHeight;

    double drawWidth;
    double drawHeight;
    double left;
    double top;

    // contain 기준
    if (imageRatio > boxRatio) {
      drawWidth = boxWidth;
      drawHeight = boxWidth / imageRatio;
      left = 0;
      top = (boxHeight - drawHeight) / 2;
    } else {
      drawHeight = boxHeight;
      drawWidth = boxHeight * imageRatio;
      left = (boxWidth - drawWidth) / 2;
      top = 0;
    }

    _displayedImageSize = Size(drawWidth, drawHeight);
    _displayedImageLeft = left;
    _displayedImageTop = top;

    // selection rect가 이미지 밖으로 나가지 않게 1회 보정
    _selectionRect = _clampRectToImageBounds(_selectionRect);
  }

  Rect _clampRectToImageBounds(Rect rect) {
    if (_displayedImageSize == null) return rect;

    final minLeft = _displayedImageLeft;
    final minTop = _displayedImageTop;
    final maxRight = _displayedImageLeft + _displayedImageSize!.width;
    final maxBottom = _displayedImageTop + _displayedImageSize!.height;

    double left = rect.left.clamp(minLeft, maxRight - 40);
    double top = rect.top.clamp(minTop, maxBottom - 40);
    double width = rect.width;
    double height = rect.height;

    if (left + width > maxRight) {
      width = maxRight - left;
    }
    if (top + height > maxBottom) {
      height = maxBottom - top;
    }

    width = width.clamp(60, _displayedImageSize!.width);
    height = height.clamp(40, _displayedImageSize!.height);

    return Rect.fromLTWH(left, top, width, height);
  }

  bool _isOnResizeHandle(Offset point) {
    final handleCenter = Offset(
      _selectionRect.right,
      _selectionRect.bottom,
    );
    return (point - handleCenter).distance <= 28;
  }

  void _onPanStart(DragStartDetails details) {
    final local = details.localPosition;

    if (_isOnResizeHandle(local)) {
      _isResizing = true;
      _isMoving = false;
    } else if (_selectionRect.contains(local)) {
      _isMoving = true;
      _isResizing = false;
    }

    _lastFocalPoint = local;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_displayedImageSize == null || _lastFocalPoint == null) return;

    final local = details.localPosition;
    final dx = local.dx - _lastFocalPoint!.dx;
    final dy = local.dy - _lastFocalPoint!.dy;

    Rect next = _selectionRect;

    if (_isMoving) {
      next = _selectionRect.shift(Offset(dx, dy));
    } else if (_isResizing) {
      final newWidth = (_selectionRect.width + dx).clamp(60.0, _displayedImageSize!.width);
      final newHeight = (_selectionRect.height + dy).clamp(40.0, _displayedImageSize!.height);

      next = Rect.fromLTWH(
        _selectionRect.left,
        _selectionRect.top,
        newWidth,
        newHeight,
      );
    }

    setState(() {
      _selectionRect = _clampRectToImageBounds(next);
      _lastFocalPoint = local;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _isMoving = false;
    _isResizing = false;
    _lastFocalPoint = null;
  }

  Future<void> _confirmCrop() async {
    if (_decodedImage == null || _displayedImageSize == null) return;

    final originalWidth = _decodedImage!.width.toDouble();
    final originalHeight = _decodedImage!.height.toDouble();

    // 화면상 선택 rect를 "이미지 내부 좌표"로 변환
    final relativeLeft = _selectionRect.left - _displayedImageLeft;
    final relativeTop = _selectionRect.top - _displayedImageTop;

    final scaleX = originalWidth / _displayedImageSize!.width;
    final scaleY = originalHeight / _displayedImageSize!.height;

    double cropLeft = relativeLeft * scaleX;
    double cropTop = relativeTop * scaleY;
    double cropWidth = _selectionRect.width * scaleX;
    double cropHeight = _selectionRect.height * scaleY;

    // padding 추가
    final horizontalPadding = cropWidth * 0.10;
    final verticalPadding = cropHeight * 0.20;

    cropLeft -= horizontalPadding;
    cropTop -= verticalPadding;
    cropWidth += horizontalPadding * 2;
    cropHeight += verticalPadding * 2;

    cropLeft = cropLeft.clamp(0, originalWidth - 1);
    cropTop = cropTop.clamp(0, originalHeight - 1);

    if (cropLeft + cropWidth > originalWidth) {
      cropWidth = originalWidth - cropLeft;
    }
    if (cropTop + cropHeight > originalHeight) {
      cropHeight = originalHeight - cropTop;
    }

    final cropped = img.copyCrop(
      _decodedImage!,
      x: cropLeft.round(),
      y: cropTop.round(),
      width: cropWidth.round(),
      height: cropHeight.round(),
    );

    final originalPath = widget.imageFile.path;
    final dotIndex = originalPath.lastIndexOf('.');
    final croppedPath = dotIndex != -1
        ? '${originalPath.substring(0, dotIndex)}_gallery_cropped.jpg'
        : '${originalPath}_gallery_cropped.jpg';

    final croppedFile = File(croppedPath);
    await croppedFile.writeAsBytes(img.encodeJpg(cropped, quality: 95));

    if (!mounted) return;
    Navigator.pop(context, croppedFile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PaliTopBar(
        title: 'gallery_crop.title'.tr(),
      ),
      body: _decodedImage == null
        ? const Center(child: CircularProgressIndicator())
        : LayoutBuilder(
            builder: (context, constraints) {
              _updateDisplayedImageRect(constraints);

              return Stack(
                children: [
                  GestureDetector(
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Center(
                            child: SizedBox(
                              width: _displayedImageSize!.width,
                              height: _displayedImageSize!.height,
                              child: Image.file(
                                widget.imageFile,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),

                        Positioned.fill(
                          child: CustomPaint(
                            painter: _CropOverlayPainter(
                              rect: _selectionRect,
                            ),
                          ),
                        ),

                        Positioned(
                          left: _selectionRect.left,
                          top: _selectionRect.top,
                          child: Container(
                            width: _selectionRect.width,
                            height: _selectionRect.height,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        Positioned(
                          left: _selectionRect.right - 14,
                          top: _selectionRect.bottom - 14,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.open_in_full,
                              size: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Text(
                        'gallery_crop.guide'.tr(),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.buttonFont,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 24,
                    child: SafeArea(
                      top: false,
                      child: PaliButton(
                        text: 'gallery_crop.done'.tr(),
                        onPressed: _confirmCrop,
                        type: PaliButtonType.primary,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
  );
  }
}

class _CropOverlayPainter extends CustomPainter {
  final Rect rect;

  _CropOverlayPainter({required this.rect});

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.65);

    final fullPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final holePath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      );

    final overlayPath = Path.combine(
      PathOperation.difference,
      fullPath,
      holePath,
    );

    canvas.drawPath(overlayPath, overlayPaint);
  }

  @override
  bool shouldRepaint(covariant _CropOverlayPainter oldDelegate) {
    return oldDelegate.rect != rect;
  }
}