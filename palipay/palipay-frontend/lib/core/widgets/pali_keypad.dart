// lib/core/widgets/pali_keypad.dart
import 'dart:math' as math;
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        // [핵심] 화면 폭에 따라 값들을 유동적으로 계산
        final horizontalPadding = screenWidth < 360
            ? 20.0
            : screenWidth < 420
                ? 28.0
                : 40.0;

        final spacing = screenWidth < 360 ? 4.0 : 6.0;

        // 실제 Grid가 사용할 폭
        final gridWidth = screenWidth - (horizontalPadding * 2);

        // 셀 1칸의 가로 길이
        final cellWidth = (gridWidth - (spacing * 2)) / 3;

        // [핵심] 버튼 높이를 가로 기준으로 잡아서 너무 납작해지지 않게 조정
        final cellHeight = math.max(58.0, math.min(74.0, cellWidth * 0.78));

        final double numberFontSize = textStyle?.fontSize ??
            (screenWidth < 360
                ? 22.0
                : screenWidth < 420
                    ? 24.0
                    : 26.0);

        final TextStyle resolvedTextStyle = (textStyle ??
                TextStyle(
                  fontSize: numberFontSize,
                  fontWeight: FontWeight.w500,
                  color: enabled
                      ? AppColors.abledFont
                      : AppColors.disabledFont,
                ))
            .copyWith(
          fontSize: textStyle?.fontSize ?? numberFontSize,
          height: textStyle?.height ?? 1.0,
          color:
              enabled ? AppColors.abledFont : AppColors.disabledFont,
        );

        final double iconSize = screenWidth < 360 ? 24.0 : 28.0;
        final double borderRadius = screenWidth < 360 ? 28.0 : 40.0;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            // [핵심] 고정 1.5 대신 계산된 셀 높이에 맞춰 비율 지정
            childAspectRatio: cellWidth / cellHeight,
            children: [
              ...List.generate(
                9,
                (index) => _buildKey(
                  value: "${index + 1}",
                  style: resolvedTextStyle,
                  height: cellHeight,
                  radius: borderRadius,
                ),
              ),

              leftButton != null
                  ? SizedBox(
                      height: cellHeight,
                      child: Center(child: leftButton),
                    )
                  : SizedBox(height: cellHeight),

              _buildKey(
                value: "0",
                style: resolvedTextStyle,
                height: cellHeight,
                radius: borderRadius,
              ),

              _buildBackspaceKey(
                height: cellHeight,
                radius: borderRadius,
                iconSize: iconSize,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKey({
    required String value,
    required TextStyle style,
    required double height,
    required double radius,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTapDown: enabled ? (_) => onNumberTap(value) : null,
        onTap: () {},
        borderRadius: BorderRadius.circular(radius),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: SizedBox(
          height: height,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Transform.translate(
                offset: const Offset(0, 1), // [추가] 윗부분 잘림 미세 보정
                child: Text(
                  value,
                  maxLines: 1,
                  style: style,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceKey({
    required double height,
    required double radius,
    required double iconSize,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTapDown: enabled ? (_) => onBackspace() : null,
        onTap: () {},
        borderRadius: BorderRadius.circular(radius),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: SizedBox(
          height: height,
          child: Center(
            child: Icon(
              Icons.backspace_outlined,
              size: iconSize,
              color: enabled
                  ? AppColors.abledFont
                  : AppColors.disabledFont,
            ),
          ),
        ),
      ),
    );
  }
}