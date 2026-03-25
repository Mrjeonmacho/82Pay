// =============================================================================
// main.dart
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/bank_provider.dart';
import 'views/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const WorldBankApp());
}

class WorldBankApp extends StatelessWidget {
  const WorldBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BankProvider(),
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
    final isDark = provider.nationality.name == 'us';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'World Bank',
      theme: isDark
          ? ThemeData.dark(useMaterial3: true)
          : ThemeData.light(useMaterial3: true),
      home: const MainScreen(),
    );
  }
}
