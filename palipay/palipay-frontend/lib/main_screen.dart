import 'package:flutter/material.dart';
import 'package:palipay_app/core/widgets/pali_nav_bars.dart';
import 'package:palipay_app/features/home/views/home_screen.dart';
import 'package:palipay_app/features/scan/views/scan_screen.dart';
import 'package:palipay_app/features/profile/views/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // [수정] ScanScreen을 탭 페이지 목록에서 제거
  // -> 카메라 화면은 navbar 내부 탭이 아니라 별도 화면으로 push
  final List<Widget> _pages = const [
    HomeScreen(), // index 0
    ProfileScreen(), // index 1
  ];

  Future<void> _handleNavTap(int index) async {
    // [수정] scan 버튼(index 2)을 누르면 탭 전환이 아니라 새 화면 push
    if (index == 2) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ScanScreen()),
      );
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: PaliTopBar(title: 'home.title'.tr()),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: PaliBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _handleNavTap,
      ),
    );
  }
}
