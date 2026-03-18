// lib/core/widgets/pali_keypad.dart

import 'package:flutter/material.dart';

class PaliKeypad extends StatelessWidget {
  final Function(String) onNumberTap;
  final VoidCallback onBackspace;
  final Widget? leftButton; // 하단 왼쪽 커스텀 버튼 (로고 등)
  final TextStyle? textStyle;

  const PaliKeypad({
    super.key,
    required this.onNumberTap,
    required this.onBackspace,
    this.leftButton,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 1.5,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // 1~9 숫자 버튼
          ...List.generate(9, (index) => _buildKey("${index + 1}")),

          // 하단 왼쪽 버튼 (커스텀)
          leftButton ?? const SizedBox.shrink(),

          // 0 숫자 버튼
          _buildKey("0"),

          // 백스페이스 버튼
          IconButton(
            onPressed: onBackspace,
            icon: const Icon(Icons.backspace_outlined, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String value) {
    return InkWell(
      onTap: () => onNumberTap(value),
      borderRadius: BorderRadius.circular(40),
      child: Center(
        child: Text(
          value,
          style:
              textStyle ??
              const TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
