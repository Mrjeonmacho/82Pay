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

  final List<Widget> _pages = const [
    HomeScreen(),     // index 0
    ProfileScreen(),  // index 1
    ScanScreen(),     // index 2
  ];

  void _handleNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: PaliBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _handleNavTap,
      ),
    );
  }
}