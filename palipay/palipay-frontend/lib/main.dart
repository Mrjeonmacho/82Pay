import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

// Core & Network
import 'package:palipay_app/core/network/dio_client.dart';
import 'package:palipay_app/core/providers/user_provider.dart';
import 'package:palipay_app/core/theme/app_colors.dart';
import 'package:palipay_app/core/theme/app_text_styles.dart';

// Features - Providers
import 'package:palipay_app/features/transfer/services/transfer_service.dart';
import 'package:palipay_app/features/transfer/providers/transfer_provider.dart';
import 'package:palipay_app/features/user/provider/delete_account_provider.dart';
import 'package:palipay_app/features/user/provider/logout_provider.dart';
import 'package:palipay_app/features/account/providers/account_provider.dart';
import 'package:palipay_app/features/wallet/providers/wallet_provider.dart';
import 'package:palipay_app/features/history/providers/history_provider.dart';
import 'package:palipay_app/features/pin/providers/pin_provider.dart';
import 'package:palipay_app/features/user/provider/sign_up_provider.dart';
import 'package:palipay_app/features/profile/providers/profile_provider.dart';
import 'package:palipay_app/features/user/provider/login_provider.dart';
import 'package:palipay_app/features/scan/providers/scan_provider.dart';

// Screens
import 'package:palipay_app/main_screen.dart';
import 'package:palipay_app/features/user/views/login_screen.dart';

void main() async {
  // 1. 플러터 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 2. 세로 모드 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 3. 라이브러리 초기화 (다국어, 환경변수, 네트워크)
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // DioClient 초기화 (인터셉터 및 쿠키 설정)
  await DioClient().init();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('ja'),
        Locale('zh'),
        Locale('ko'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const PaliPayApp(),
    ),
  );
}

class PaliPayApp extends StatelessWidget {
  const PaliPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 🚀 [수정] UserProvider 생성 시 context를 전달하여 checkLoginStatus를 실행합니다.
        // 이를 통해 저장된 국적 정보에 맞춰 앱 언어를 자동으로 세팅합니다.
        ChangeNotifierProvider(
          create: (context) => UserProvider()..checkLoginStatus(context),
        ),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => SignUpProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => PinProvider()),
        ChangeNotifierProvider(create: (_) => ScanProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(
          create: (_) => TransferProvider(TransferService()),
        ),
        ChangeNotifierProvider(create: (_) => DeleteAccountProvider()),
        ChangeNotifierProvider(create: (_) => LogoutProvider()),
      ],
      child: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          return MaterialApp(
            title: 'PaliPay',
            debugShowCheckedModeBanner: false,

            // --- 다국어 설정 연결 ---
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,

            theme: ThemeData(
              useMaterial3: true,
              fontFamily: 'Pretendard',
              scaffoldBackgroundColor: AppColors.background,
              appBarTheme: const AppBarTheme(
                toolbarHeight: 64,
                backgroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
                titleTextStyle: AppTextStyles.headlineLarge,
                iconTheme: IconThemeData(color: AppColors.abledFont),
              ),
            ),

            // 🚀 분기 로직
            // 1. isFirstCheck: 금고를 뒤지는 동안은 로딩 화면을 보여줌
            // 2. isLoggedIn: 확인 완료 후 결과에 따라 메인 또는 로그인으로 이동
            home: userProvider.isFirstCheck
                ? const Scaffold(
                    backgroundColor: Colors.white,
                    body: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.mainBlue,
                      ),
                    ),
                  )
                : (userProvider.isLoggedIn
                      ? const MainScreen()
                      : const LoginScreen()),
          );
        },
      ),
    );
  }
}
