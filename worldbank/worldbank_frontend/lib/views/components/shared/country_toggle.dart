// =============================================================================
// shared/country_toggle.dart
// 상단/하단에 붙는 국가 전환 탭 바 (모든 국가 View에서 공유)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/bank_model.dart';
import '../../../providers/bank_provider.dart';

class CountryToggle extends StatelessWidget {
  /// 활성 탭의 배경색
  final Color activeColor;

  /// 비활성 텍스트색
  final Color inactiveTextColor;

  /// 토글 컨테이너 배경색
  final Color backgroundColor;

  /// 테두리 표시 여부 (US 다크모드용)
  final bool showBorder;

  const CountryToggle({
    super.key,
    required this.activeColor,
    required this.inactiveTextColor,
    required this.backgroundColor,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BankProvider>();
    final current = provider.nationality;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: showBorder ? Border.all(color: Colors.white12) : null,
      ),
      child: Row(
        children: BankNationality.values.map((n) {
          final isActive = n == current;
          return Expanded(
            child: GestureDetector(
              onTap: () => provider.switchNationality(n),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: isActive ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    n.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                      color: isActive ? Colors.white : inactiveTextColor,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
