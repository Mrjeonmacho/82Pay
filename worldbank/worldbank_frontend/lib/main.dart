// =============================================================================
// main.dart
// =============================================================================

// =============================================================================
// main.dart
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/bank_provider.dart';
import 'providers/auth_provider.dart';
import 'views/main_screen.dart';
import 'views/splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await dotenv.load(fileName: ".env");
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      // 지원하는 언어 리스트 (영어, 한국어, 일본어, 중국어)
      supportedLocales: const [
        Locale('en'),
        Locale('ko'),
        Locale('ja'),
        Locale('zh'),
      ],
      // 번역 파일 경로
      path: 'assets/translations',
      // 설정된 언어가 없을 때 기본으로 보여줄 언어
      fallbackLocale: const Locale('ko'),
      child: const WorldBankApp(),
    ),
  );
}

class WorldBankApp extends StatelessWidget {
  const WorldBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BankProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const _AppRoot(),
    );
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    // Provider에서 현재 nationality 감지 → MaterialApp theme 반응형 전환
    final provider = context.watch<BankProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'World Bank',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: const SplashScreen(),
      // home: const MainScreen(),
    );
  }
}
