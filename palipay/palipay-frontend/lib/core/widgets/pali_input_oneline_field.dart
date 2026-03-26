import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class PaliInputOnelineField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType? keyboardType;
  final int? maxLength;
  final ValueChanged<String>? onChanged; // PIN 자동 넘기기 등을 위해 추가
  final VoidCallback? onMaxLengthExceeded;
  final TextAlign textAlign;
  final List<TextInputFormatter>? inputFormatters; // 금액 포맷팅: 3자리수마다 , 표시
  final String? errorText; // 추가

  const PaliInputOnelineField({
    super.key,
    required this.hintText,
    this.controller,
    this.isPassword = false,
    this.keyboardType,
    this.maxLength,
    this.onChanged,
    this.onMaxLengthExceeded,
    this.textAlign = TextAlign.start,
    this.inputFormatters,
    this.errorText, // 추가
  });

  @override
  Widget build(BuildContext context) {
    final formatters = <TextInputFormatter>[
      ...?inputFormatters,
      if (maxLength != null)
        _MaxLengthBlockFormatter(
          maxLength: maxLength!,
          onExceeded: onMaxLengthExceeded,
        ),
    ];

    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      maxLength: maxLength,
      onChanged: onChanged,
      textAlign: textAlign,
      inputFormatters: formatters,
      style: AppTextStyles.bodyMedium, // 입력 시 스타일
      cursorColor: AppColors.mainBlue, // 커서 색상도 메인 블루로 통일
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: AppColors.exampleFont, // #BCB6B6
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        // 토스 스타일은 배경을 채우지 않고 선만 강조합니다.
        filled: false,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        // 1. 기본 밑줄 스타일
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.disabledBackground, // 평상시 연한 회색 선
            width: 1.5,
          ),
        ),
        // 2. 클릭(포커스) 시 밑줄 스타일
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.mainBlue, // 클릭 시 파란색 선으로 강조
            width: 2.0,
          ),
        ),
        // 3. 에러 발생 시 스타일 (필요 시)
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2.0),
        ),
        errorText: errorText, // 추가
        // 글자 수 제한(counter) 텍스트 숨기기 (깔끔한 UI를 위해)
        counterText: '',
      ),
    );
  }
}

class _MaxLengthBlockFormatter extends TextInputFormatter {
  final int maxLength;
  final VoidCallback? onExceeded;

  _MaxLengthBlockFormatter({required this.maxLength, this.onExceeded});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length > maxLength) {
      onExceeded?.call();
      return oldValue;
    }
    return newValue;
  }
}
