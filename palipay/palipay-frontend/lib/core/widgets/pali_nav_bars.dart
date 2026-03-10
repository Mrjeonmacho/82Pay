import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// Top Bar
class PaliTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  const PaliTopBar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 64, //
      backgroundColor: Colors.white,
      centerTitle: true,
      title: Text(
        title,
        style: AppTextStyles.headlineLarge.copyWith(color: AppColors.mainBlue),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}

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
    return Stack(
      clipBehavior: Clip.none, // 중앙 버튼 돌출을 위해 설정
      alignment: Alignment.bottomCenter,
      children: [
        // 하단 바 본체 (배경: #FFFFFF, 높이: 64h)
        Container(
          height: 64, //
          decoration: const BoxDecoration(
            color: Colors.white, //
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
              _buildNavItem(Icons.home_filled, 'Home', 0),
              const SizedBox(width: 80), // 중앙 Scan 버튼 자리를 위한 여백
              _buildNavItem(Icons.person_outline, 'Profile', 1),
            ],
          ),
        ),

        // 돌출형 Scan 버튼 레이아웃
        Positioned(
          top: -28, // 이미지와 동일하게 바 위로 돌출
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => onTap(2),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.mainBlue, // #121380
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4), // 흰색 테두리
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
                'Scan',
                style: AppTextStyles.bodySmall.copyWith(
                  color: currentIndex == 2
                      ? AppColors.mainBlue
                      : AppColors.exampleFont, //
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
    final color = isSelected
        ? AppColors.mainBlue
        : AppColors.exampleFont; // #121380 vs #BCB6B6

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24), // 24pt 규격
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
    );
  }
}
