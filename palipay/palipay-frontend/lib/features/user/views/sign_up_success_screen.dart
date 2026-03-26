import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';

import 'login_screen.dart';

class SignUpSuccessScreen extends StatelessWidget {
  const SignUpSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // 환영 아이콘 또는 이미지
              Icon(
                Icons.check_circle_rounded,
                size: screenWidth * 0.25,
                color: AppColors.mainBlue, // 혹은 Colors.green
              ),
              SizedBox(height: screenHeight * 0.04),

              Text(
                'sign_up_success.welcome'.tr(),
                style: AppTextStyles.titleLarge.copyWith(fontSize: 28),
              ),
              SizedBox(height: screenHeight * 0.02),

              Text(
                'sign_up_success.success_desc'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const Spacer(),

              // 시작하기 버튼
              PaliButton(
                text: 'sign_up_success.btn_sign_in'.tr(),
                onPressed: () {
                  // 홈 화면으로 이동 (스택을 모두 비우고 이동하는 것이 좋음)
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
                backgroundColor: AppColors.mainBlue,
              ),
              SizedBox(height: screenHeight * 0.025),
            ],
          ),
        ),
      ),
    );
  }
}
