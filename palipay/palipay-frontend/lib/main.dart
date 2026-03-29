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
import 'package:palipay_app/core/utils/route_observers.dart';

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
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await DioClient().init();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ja'), Locale('zh')],
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
        ChangeNotifierProvider(create: (_) => UserProvider()),
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
      // AppBootstrap이 UserProvider + AccountProvider 초기화를 순서대로 처리
      child: const AppBootstrap(),
    );
  }
}

/// 앱 시작 시 Provider 초기화 순서를 보장하는 위젯
/// 1. UserProvider.checkLoginStatus() — 토큰/유저 복구
/// 2. AccountProvider.refreshWalletInfo() — 지갑 상태 복구 (로그인된 경우만)
class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final userProvider = context.read<UserProvider>();
    final accountProvider = context.read<AccountProvider>();

    // 1. 토큰 및 유저 정보 복구
    await userProvider.checkLoginStatus(context);

    // 2. 로그인 상태일 때만 지갑 정보 복구
    if (userProvider.isLoggedIn && context.mounted) {
      await accountProvider.refreshWalletInfo(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        return MaterialApp(
          title: 'PaliPay',
          debugShowCheckedModeBanner: false,
          navigatorObservers: [routeObserver],
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
          // isFirstCheck 동안 로딩 → 완료 후 로그인 여부로 분기
          home: userProvider.isFirstCheck
              ? const Scaffold(
                  backgroundColor: Colors.white,
                  body: Center(
                    child: CircularProgressIndicator(color: AppColors.mainBlue),
                  ),
                )
              : (userProvider.isLoggedIn
                    ? const MainScreen()
                    : const LoginScreen()),
        );
      },
    );
  }
}
