import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';  // 환경변수
import 'package:easy_localization/easy_localization.dart';  // 다국어

import 'package:provider/provider.dart';
import 'features/account/providers/account_provider.dart';
import 'features/wallet/providers/wallet_provider.dart';
import 'features/scan/providers/scan_provider.dart'; 
import 'features/history/providers/history_provider.dart';
import 'features/pin/providers/pin_provider.dart';
import 'features/transfer/providers/transfer_provider.dart';
import 'features/user/provider/sign_up_provider.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/user/provider/login_provider.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';

import 'package:palipay_app/main_screen.dart';
import 'package:palipay_app/features/user/views/login_screen.dart';

void main() async {
  // 1. Flutter 바인딩 초기화 (비동기 main 함수 필수 단계)
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized(); // 다국어 사용 위한 초기화 필수!

  // 2. .env 파일 로드
  try {
    await dotenv.load(fileName: ".env");
    debugPrint("✅ .env 로드 성공: ${dotenv.env['BASE_URL']}"); // 로드 확인용
  } catch (e) {
    debugPrint("❌ .env 로드 실패: $e");
  }
  runApp(
    // 1순위: 다국어 설정이 가장 바깥을 감쌉니다.
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ja'), Locale('zh')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'), // 무조건 영어로 세팅
      // 2순위: 그 안에 상태 관리(Provider)를 넣습니다.
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AccountProvider()),
          ChangeNotifierProvider(create: (_) => HistoryProvider()),
          ChangeNotifierProvider(create: (_) => WalletProvider()),
          ChangeNotifierProvider(create: (_) => SignUpProvider()),
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
          ChangeNotifierProvider(create: (_) => PinProvider()),
          ChangeNotifierProvider(create: (_) => TransferProvider()),
          ChangeNotifierProvider(create: (_) => ScanProvider()),
          ChangeNotifierProvider(create: (_) => LoginProvider()),
        ],
        // 3순위: 마지막으로 우리 앱을 실행합니다.
        child: const PaliPayApp(),
      ),
    ),
  );
}

class PaliPayApp extends StatelessWidget {
  const PaliPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PaliPay',
      // --- localizations를 위한 필수 설정 ---
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      // ------------------------
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Pretendard', // 전역 폰트 설정
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
      home: LoginScreen(),
      // home: MainScreen(),
    );
  }
}
