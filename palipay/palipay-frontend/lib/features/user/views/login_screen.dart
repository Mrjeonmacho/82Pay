import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/pali_input_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 60),
            Text(
              'Welcome!',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.mainBlue, // 앱 기본 텍스트 색상
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // 이메일 입력창
            const PaliInputField(hintText: 'Email'),
            const SizedBox(height: 16),

            // 비밀번호 입력창
            const PaliInputField(hintText: 'Password'),
            const SizedBox(height: 24),

            // 앱 기본 Primary 컬러가 적용되는 로그인 버튼
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              child: const Text('Login', style: AppTextStyles.labelLarge),
            ),

            const SizedBox(height: 32),

            // 구분선 섹션
            Row(
              children: [
                Expanded(child: Divider(color: AppColors.mainBlue)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Or', style: AppTextStyles.bodySmall),
                ),
                Expanded(child: Divider(color: AppColors.mainBlue)),
              ],
            ),

            const SizedBox(height: 32),

            // 구글 소셜 로그인 버튼
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: AppColors.mainBlue), // 앱 기본 선 색상
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logos/google.png', height: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Continue with Google',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.mainBlue,
                      height: 2.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
