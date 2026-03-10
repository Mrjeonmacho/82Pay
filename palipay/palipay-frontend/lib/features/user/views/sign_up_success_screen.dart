import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';

class SignUpSuccessScreen extends StatelessWidget {
  const SignUpSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // 환영 아이콘 또는 이미지
              const Icon(
                Icons.check_circle_rounded,
                size: 100,
                color: AppColors.mainBlue, // 혹은 Colors.green
              ),
              const SizedBox(height: 30),

              Text(
                'Welcome to Pali!',
                style: AppTextStyles.titleLarge.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 16),

              const Text(
                '회원가입이 성공적으로 완료되었습니다.\n지금 바로 서비스를 시작해보세요!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16, height: 1.5),
              ),
              const Spacer(),

              // 시작하기 버튼
              PaliButton(
                text: '시작하기',
                onPressed: () {
                  // 홈 화면으로 이동 (스택을 모두 비우고 이동하는 것이 좋음)
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                  );
                },
                backgroundColor: AppColors.mainBlue,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
