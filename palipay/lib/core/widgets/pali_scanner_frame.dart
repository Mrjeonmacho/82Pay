import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PaliScannerFrame extends StatelessWidget {
  const PaliScannerFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(280, 200), // 스캔 영역 크기
      painter: ScannerPainter(),
    );
  }
}

class ScannerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final redPaint = Paint()
      ..color = AppColors.warningRed
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    final bluePaint = Paint()
      ..color = AppColors.mainBlue
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    const double len = 30; // 모서리 선 길이

    // 상단 (Red)
    canvas.drawPath(
      Path()
        ..moveTo(0, len)
        ..lineTo(0, 0)
        ..lineTo(len, 0),
      redPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width - len, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, len),
      redPaint,
    );

    // 하단 (Blue)
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - len)
        ..lineTo(0, size.height)
        ..lineTo(len, size.height),
      bluePaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width - len, size.height)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width, size.height - len),
      bluePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
