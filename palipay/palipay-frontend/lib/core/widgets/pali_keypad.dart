// lib/core/widgets/pali_keypad.dart

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PaliKeypad extends StatelessWidget {
  final Function(String) onNumberTap;
  final VoidCallback onBackspace;
  final Widget? leftButton; // 하단 왼쪽 커스텀 버튼 (로고 등)
  final TextStyle? textStyle;
  final bool enabled; // [추가]
  

  const PaliKeypad({
    super.key,
    required this.onNumberTap,
    required this.onBackspace,
    this.leftButton,
    this.textStyle,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = textStyle ??
        TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w500,
          color: enabled ? AppColors.abledFont : AppColors.disabledFont,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1.5,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // 1~9 숫자 버튼
          ...List.generate(9, (index) => _buildKey("${index + 1}", defaultStyle)),

          // 하단 왼쪽 버튼 (커스텀)
          leftButton ?? const SizedBox.shrink(),

          // 0 숫자 버튼
          _buildKey("0", defaultStyle),

          // 백스페이스 버튼
          _buildBackspaceKey(),
        ],
      ),
    );
  }

  Widget _buildKey(String value, TextStyle style) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTapDown: enabled ? (_) => onNumberTap(value) : null,
        onTap: () {}, // onTapDown만 쓰면 경고/동작 꼬일 수 있어서 빈 onTap 유지
        borderRadius: BorderRadius.circular(40),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16), // 👈 핵심
          alignment: Alignment.center,
          child: Text(value, style: style),
        ),
      ),
    );
  }

  Widget _buildBackspaceKey() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTapDown: enabled ? (_) => onBackspace() : null,
        onTap: () {},
        borderRadius: BorderRadius.circular(40),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: Icon(
            Icons.backspace_outlined,
            size: 28,
            color: enabled ? AppColors.abledFont : AppColors.disabledFont,
          ),
        ),
      ),
    );
  }
}