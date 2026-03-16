// 글씨 스타일 정의
import 'package:flutter/material.dart';
import 'app_colors.dart';

class PreTextStyles {
  static const String fontFamily = 'Pretendard';
  // Title Large - 완료 화면 큰 글씨
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w900, // Heavy
    color: AppColors.abledFont,
    letterSpacing: -0.5,
  );

  // Headline Large - 상단바 이름
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w800, // ExtraBold
    color: AppColors.abledFont,
  );

  // Title Medium - 마이페이지 섹션 제목
  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: AppColors.abledFont,
  );

  // Label Large - Confirm 버튼용
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w800, // ExtraBold
    color: AppColors.buttonFont,
  );

  // Body Large - 메인 글씨 1
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.abledFont,
  );

  // Body Large - 메인 글씨 2
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: AppColors.abledFont,
  );

  // Body Small - main detail / scan / 메인 글씨 3
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.exampleFont,
  );
}
