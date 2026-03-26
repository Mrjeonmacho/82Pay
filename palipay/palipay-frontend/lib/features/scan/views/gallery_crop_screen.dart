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

  const GalleryCropScreen({super.key, required this.imageFile});

  @override
  State<GalleryCropScreen> createState() => _GalleryCropScreenState();
}

class _GalleryCropScreenState extends State<GalleryCropScreen> {
  Rect _selectionRect = Rect.zero;

  Size? _displayedImageSize;
  double _displayedImageLeft = 0;
  double _displayedImageTop = 0;

  img.Image? _decodedImage;

  bool _isMoving = false;
  bool _isResizing = false;
  bool _isSelectionInitailized = false;
  Offset? _lastFocalPoint;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  double _clamp(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
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

    if (!_isSelectionInitailized) {
      final rectWidth = _clamp(drawWidth * 0.72, 160, drawWidth);
      final rectHeight = _clamp(drawHeight * 0.22, 70, drawHeight * 0.45);
      final rectLeft = left + (drawWidth - rectWidth) / 2;
      final rectTop = top + (drawHeight - rectHeight) / 2;

      _selectionRect = Rect.fromLTWH(rectLeft, rectTop, rectWidth, rectHeight);
      _isSelectionInitailized = true;
    } else {
      _selectionRect = _clampRectToImageBounds(_selectionRect);
    }
  }

  Rect _clampRectToImageBounds(Rect rect) {
    if (_displayedImageSize == null) return rect;

    final minWidth = _clamp(_displayedImageSize!.width * 0.18, 80, 180);
    final minHeight = _clamp(_displayedImageSize!.height * 0.10, 50, 120);

    final minLeft = _displayedImageLeft;
    final minTop = _displayedImageTop;
    final maxRight = _displayedImageLeft + _displayedImageSize!.width;
    final maxBottom = _displayedImageTop + _displayedImageSize!.height;

    double left = rect.left;
    double top = rect.top;
    double width = rect.width;
    double height = rect.height;

    width = width.clamp(minWidth, _displayedImageSize!.width);
    height = height.clamp(minHeight, _displayedImageSize!.height);

    left = left.clamp(minLeft, maxRight - width);
    top = top.clamp(minTop, maxBottom - height);

    if (left + width > maxRight) {
      width = maxRight - left;
    }
    if (top + height > maxBottom) {
      height = maxBottom - top;
    }

    return Rect.fromLTWH(left, top, width, height);
  }

  bool _isOnResizeHandle(Offset point) {
    if (_displayedImageSize == null) return false;

    final handleTouchRadius = _clamp(_displayedImageSize!.width * 0.07, 24, 32);

    final handleCenter = Offset(_selectionRect.right, _selectionRect.bottom);
    return (point - handleCenter).distance <= handleTouchRadius;
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

    final minWidth = _clamp(_displayedImageSize!.width * 0.18, 80, 180);
    final minHeight = _clamp(_displayedImageSize!.height * 0.10, 50, 120);

    if (_isMoving) {
      next = _selectionRect.shift(Offset(dx, dy));
    } else if (_isResizing) {
      final newWidth = (_selectionRect.width + dx).clamp(
        minWidth,
        _displayedImageSize!.width,
      );
      final newHeight = (_selectionRect.height + dy).clamp(
        minHeight,
        _displayedImageSize!.height,
      );

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
      appBar: PaliTopBar(title: 'gallery_crop.title'.tr()),
      body: _decodedImage == null
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                _updateDisplayedImageRect(constraints);

                final width = constraints.maxWidth;
                final height = constraints.maxHeight;
                final safeBottom = MediaQuery.of(context).padding.bottom;

                final horizontalPadding = _clamp(width * 0.045, 14, 22);
                final topGuide = _clamp(height * 0.02, 12, 20);
                final bottomButton = safeBottom + _clamp(height * 0.02, 10, 18);

                final handleSize = _clamp(width * 0.075, 24, 30);
                final handleIconSize = _clamp(handleSize * 0.58, 14, 18);
                final borderRadius = _clamp(width * 0.03, 10, 14);
                final guideFontSize = _clamp(width * 0.037, 13, 15);

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
                                borderRadius: borderRadius,
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
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                          Positioned(
                            left: _selectionRect.right - handleSize / 2,
                            top: _selectionRect.bottom - handleSize / 2,
                            child: Container(
                              width: handleSize,
                              height: handleSize,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  handleSize / 2,
                                ),
                              ),
                              child: Icon(
                                Icons.open_in_full,
                                size: handleIconSize,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Positioned(
                      top: topGuide,
                      left: horizontalPadding,
                      right: horizontalPadding,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: _clamp(width * 0.04, 12, 16),
                          vertical: _clamp(height * 0.012, 8, 10),
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
  final double borderRadius;

  _CropOverlayPainter({required this.rect, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.65);

    final fullPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final holePath = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)));

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
