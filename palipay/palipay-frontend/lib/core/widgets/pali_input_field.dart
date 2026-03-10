import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // FilteringTextInputFormatter 사용을 위해 필요
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class PaliInputField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType? keyboardType; // 추가된 변수
  final int? maxLength; // 추가된 변수
  final ValueChanged<String>? onChanged; // 추가된 변수

  const PaliInputField({
    super.key,
    required this.hintText,
    this.controller,
    this.isPassword = false,
    this.keyboardType, // 생성자에 추가
    this.maxLength, // 생성자에 추가
    this.onChanged, // 옵션
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType, // 실제 TextField에 전달
      maxLength: maxLength, // 실제 TextField에 전달
      onChanged: onChanged,
      style: AppTextStyles.bodyMedium, // 입력 시 16pt, Bold
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: AppColors.exampleFont, // #BCB6B6 적용
          fontSize: 14,
          fontWeight: FontWeight.w500, // Body Medium 대응
        ),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.disabledBackground),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.mainBlue, width: 2),
        ),
      ),
    );
  }
}
