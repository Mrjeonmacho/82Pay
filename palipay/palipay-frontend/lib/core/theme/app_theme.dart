// main.dart에 적용할 전역 테마
// 상단바 높이, 배경색 등 미리 세팅

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.mainBlue,

      // AppBar 공통 규격 (64h)
      appBarTheme: const AppBarTheme(
        toolbarHeight: 64,
        backgroundColor: AppColors.background,
        elevation: 0,
        titleTextStyle: AppTextStyles.headlineLarge,
        iconTheme: IconThemeData(color: AppColors.abledFont),
      ),

      // 공통 텍스트 테마 적용
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.titleLarge,
        headlineLarge: AppTextStyles.headlineLarge,
        bodyLarge: AppTextStyles.bodyLarge,
        bodySmall: AppTextStyles.bodySmall,
      ),
    );
  }
}
