import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart'; // 환경변수
import 'package:easy_localization/easy_localization.dart'; // 다국어
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 👈 이거 추가!

import 'package:dio/dio.dart';
import 'package:palipay_app/core/network/dio_client.dart';
import 'package:palipay_app/core/providers/user_provider.dart';
import 'package:palipay_app/features/transfer/services/transfer_service.dart';
import 'package:palipay_app/features/transfer/providers/transfer_provider.dart';
import 'package:palipay_app/features/user/provider/delete_account_provider.dart';
import 'package:palipay_app/features/user/provider/logout_provider.dart';

import 'package:provider/provider.dart';
import 'core/providers/user_provider.dart';
import 'features/account/providers/account_provider.dart';
import 'features/wallet/providers/wallet_provider.dart';
import 'features/history/providers/history_provider.dart';
import 'features/pin/providers/pin_provider.dart';
import 'features/user/provider/sign_up_provider.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/user/provider/login_provider.dart';
import 'features/scan/providers/scan_provider.dart'; // [수정] 추가

import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';

import 'package:palipay_app/main_screen.dart';
import 'package:palipay_app/features/user/views/login_screen.dart';
import 'package:palipay_app/features/wallet/views/wallet_topup_view.dart';

void main() async {
  // 1. 플러터 엔진과 통신 준비
  WidgetsFlutterBinding.ensureInitialized();

  // 💡 [여기 추가] 앱 전체를 세로 모드로 고정합니다.
  // portraitUp: 정방향 세로, portraitDown: 역방향 세로
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 2. 다국어 설정 초기화 (이게 빠지면 null 에러 발생!)
  await EasyLocalization.ensureInitialized();

  // 3. .env 설정 로드
  await dotenv.load(fileName: ".env");

  await DioClient().init();

  // 2. [추가] 금고에서 토큰이 있는지 확인 (자동 로그인 여부 판단)
  const storage = FlutterSecureStorage();
  String? token = await storage.read(key: 'accessToken');
  String? walletId = await storage.read(
    key: 'walletId',
  ); // 💾 walletId도 저장되어 있다면 읽어옴
  String? userName = await storage.read(key: 'userName');

  // 🔍 디버깅용 로그: 토큰이 정말 있는지 확인!
  debugPrint('🚀 [Startup] 저장된 토큰: $token');

  bool isLoggedIn = token != null && token.isNotEmpty;
  runApp(
    // 4. 앱 전체를 EasyLocalization으로 감싸야 함
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ja'), Locale('zh')],
      path: 'assets/translations', // 번역 파일 경로 확인!
      fallbackLocale: const Locale('en'),
      child: PaliPayApp(
        isLoggedIn: isLoggedIn,
        token: token,
        walletId: walletId,
        userName: userName,
      ),
    ),
  );
}

class PaliPayApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? token;
  final String? walletId;
  final String? userName;

  const PaliPayApp({
    super.key,
    required this.isLoggedIn,
    this.token,
    this.walletId,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final userProvider = UserProvider();
            if (isLoggedIn && token != null) {
              userProvider.restoreUser(
                token: token!,
                walletId: walletId,
                userName: userName,
              );
            }
            return userProvider;
          },
        ),
        // 추후 생성할 Provider들을 여기에 등록하세요.
        // ChangeNotifierProvider(create: (_) => UserProvider()),
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
      child: MaterialApp(
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

        // home: const LoginScreen(), // 혹은 시작 화면
        // 로그인 되어 있으면 메인 화면, 아니면 로그인 화면
        home: isLoggedIn ? const MainScreen() : const LoginScreen(),
        // home: const MainScreen(),
        // home: TopupView()
      ),
    );
  }
}
