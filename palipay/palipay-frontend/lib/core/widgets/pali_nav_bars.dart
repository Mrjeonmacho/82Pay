import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// --- 1. 상단 바 (PaliTopBar) ---
class PaliTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  const PaliTopBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    // 🚀 언어 변경 감지를 위한 트리거
    context.locale;

    return AppBar(
      toolbarHeight: 64,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: true,
      leading: leading,
      title: Text(
        title, // 호출하는 곳에서 'key'.tr()로 넘겨주어야 합니다.
        style: AppTextStyles.headlineLarge.copyWith(
          color: AppColors.mainBlue,
          fontWeight: FontWeight.w900,
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}

// --- 2. 하단 바 (PaliBottomNavigationBar) ---
class PaliBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const PaliBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 🚀 [중요] 이 한 줄이 있어야 다국어 변경 시 내비바가 리빌드됩니다.
    context.locale;

    return Stack(
      clipBehavior: Clip.none, // 중앙 버튼 돌출을 위해 필수
      alignment: Alignment.bottomCenter,
      children: [
        // 하단 바 본체
        Container(
          height: 64,
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(Icons.home_filled, 'common.home'.tr(), 0),
              const SizedBox(width: 80), // 중앙 Scan 버튼 자리를 위한 여백
              _buildNavItem(Icons.person_outline, 'common.profile'.tr(), 1),
            ],
          ),
        ),

        // 돌출형 Scan 버튼 레이아웃
        Positioned(
          top: -28, // 바 위로 돌출되는 높이
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => onTap(2),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.mainBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'common.scan'.tr(), // 실시간 번역 적용
                style: AppTextStyles.bodySmall.copyWith(
                  color: currentIndex == 2
                      ? AppColors.mainBlue
                      : AppColors.exampleFont,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 개별 아이콘 및 라벨 생성 함수
  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.mainBlue : AppColors.exampleFont;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
