import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:palipay_app/features/history/providers/history_provider.dart';
import 'package:palipay_app/features/user/provider/sign_up_provider.dart';
import 'package:provider/provider.dart';
import 'package:palipay_app/main_screen.dart';
import 'features/account/providers/account_provider.dart';
import 'features/wallet/providers/wallet_provider.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';

void main() async {
  // 1. Flutter 바인딩 초기화 (비동기 main 함수 필수 단계)
  WidgetsFlutterBinding.ensureInitialized();

  // 2. .env 파일 로드
  try {
    await dotenv.load(fileName: ".env");
    debugPrint("✅ .env 로드 성공: ${dotenv.env['BASE_URL']}"); // 로드 확인용
  } catch (e) {
    debugPrint("❌ .env 로드 실패: $e");
  }
  runApp(
    // const PaliPayApp(),
    // 3인 협업을 위한 전역 상태 관리 세팅
    MultiProvider(
      providers: [
        // 추후 생성할 Provider들을 여기에 등록하세요.
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => SignUpProvider()),
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
      // 시작 화면을 분리된 MainScreen으로 설정
      home: const MainScreen(),
    );
  }
}
