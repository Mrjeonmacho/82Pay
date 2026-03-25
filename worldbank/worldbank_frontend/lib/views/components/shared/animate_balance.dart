// =============================================================================
// shared/animate_balance.dart
// 잔액 숫자 카운터 애니메이션 위젯 — 모든 국가 View에서 공유
// =============================================================================

import 'package:flutter/material.dart';

class AnimateBalance extends StatelessWidget {
  final double balance;
  final TextStyle style;
  final String Function(double) formatter;

  const AnimateBalance({
    super.key,
    required this.balance,
    required this.style,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: balance),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOut,
      builder: (_, value, __) => Text(formatter(value), style: style),
    );
  }
}
