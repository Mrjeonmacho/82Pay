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
<<<<<<< HEAD
  final ValueChanged<String>? onChanged; // 추가된 변수
  final bool useShadow; // 그림자 사용 여부
=======
  final String? Function(String?)? validator; // input 데이터 검증용
  final void Function(String)? onChanged;
  final Widget? suffixIcon;
>>>>>>> frontend/palipay

  const PaliInputField({
    super.key,
    required this.hintText,
    this.controller,
    this.isPassword = false,
    this.keyboardType, // 생성자에 추가
    this.maxLength, // 생성자에 추가
<<<<<<< HEAD
    this.onChanged, // 옵션
    this.useShadow = false, // 기존 false
=======
    this.validator,
    this.onChanged,
    this.suffixIcon,
>>>>>>> frontend/palipay
  });

   @override
  Widget build(BuildContext context) {
<<<<<<< HEAD

    final input = TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      maxLength: maxLength,
      onChanged: onChanged,
      style: AppTextStyles.bodyMedium,
=======
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType, // 실제 TextField에 전달
      maxLength: maxLength, // 실제 TextField에 전달
      validator: validator,
      onChanged: onChanged,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: AppTextStyles.bodyMedium, // 입력 시 16pt, Bold
>>>>>>> frontend/palipay
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: AppColors.exampleFont,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        errorStyle: const TextStyle(
          color: AppColors.warningRed,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.0,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.buttonFont,
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
          borderSide: const BorderSide(
            color: AppColors.mainBlue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.warningRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.warningRed, width: 2),
        ),
      ),
    );

    // 그림자 안쓰는 경우
    if (!useShadow) return input;

    // 그림자 쓰는 경우
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: input,
    );
  }
}
