import 'package:flutter/material.dart';
import 'login_screen.dart'; // 로그인 화면 임포트
import 'package:easy_localization/easy_localization.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? _selectedLanguage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 현재 설정된 언어에 맞춰 드롭다운 표시 업데이트
    final locale = context.locale.languageCode;
    if (locale == 'ko') {
      _selectedLanguage = '한국어';
    } else if (locale == 'zh') {
      _selectedLanguage = '中文';
    } else if (locale == 'ja') {
      _selectedLanguage = '日本語';
    } else {
      _selectedLanguage = 'English';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // 1. 중앙 로고
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/worldlogo.png', // 로고 경로
                      height: 150,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "World Bank",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // 2. 언어 선택 드롭다운 (글로벌 서비스 느낌)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLanguage,
                    isExpanded: true,
                    icon: const Icon(Icons.language, color: Colors.grey),
                    items: ['English', '한국어', '中文', '日本語']
                        .map(
                          (lang) =>
                              DropdownMenuItem(value: lang, child: Text(lang)),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() => _selectedLanguage = val!);
                      // 2. 실제 언어 변경 로직 추가
                      if (val == '한국어') {
                        context.setLocale(const Locale('ko'));
                      } else if (val == 'English') {
                        context.setLocale(const Locale('en'));
                      } else if (val == '中文') {
                        context.setLocale(const Locale('zh'));
                      } else if (val == '日本語') {
                        context.setLocale(const Locale('ja'));
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 3. 시작하기 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // 로그인 화면으로 이동 (스플래시를 스택에서 제거)
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE2D696),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "splash.get_started".tr(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
