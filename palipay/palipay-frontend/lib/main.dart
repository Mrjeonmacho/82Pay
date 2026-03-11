import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:palipay_app/features/profile/views/profile_screen.dart';
import 'package:palipay_app/features/scan/views/scan_screen.dart';
import 'package:palipay_app/features/scan/views/account_input_screen.dart';
import 'package:palipay_app/features/scan/views/amount_input_screen.dart';
=======
import 'package:palipay_app/features/user/views/sign_up_screen.dart';
import 'package:palipay_app/features/history/providers/history_provider.dart';
>>>>>>> frontend/palipay
import 'package:provider/provider.dart';
import 'features/home/views/home_screen.dart';
import 'features/account/providers/account_provider.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';

void main() {
  runApp(
    // const PaliPayApp(),
    // 3인 협업을 위한 전역 상태 관리 세팅
    MultiProvider(
      providers: [
        // 추후 생성할 Provider들을 여기에 등록하세요.
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ],
      child: const PaliPayApp(),
    ),
  );
}

class PaliPayApp extends StatelessWidget {
  const PaliPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PaliPay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'SUIT', // 전역 폰트 설정
        scaffoldBackgroundColor: AppColors.background, // #F5F5F8
        // 상단바 공통 규격 (64h) 적용
        appBarTheme: const AppBarTheme(
          toolbarHeight: 64,
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: AppTextStyles.headlineLarge,
          iconTheme: IconThemeData(color: AppColors.abledFont),
        ),

        // 하단바 돌출 버튼을 위한 전역 설정
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.mainBlue,
          foregroundColor: Colors.white,
        ),
      ),
      // 시작 화면을 분리된 HomeScreen으로 설정
      // home: const HomeScreen(),
      // home: const ProfileScreen(),
      home: const ScanScreen(),
      // home: const AccountInputScreen(),
      // home: const AmountInputScreen(bankName: '농협', accountNumber: '123456')
    );
  }
}
