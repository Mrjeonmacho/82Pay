import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider 임포트 추가
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../pin/views/pin_screen.dart';
import '../../pin/providers/pin_provider.dart';
import '../../account/views/bank_selection_view.dart';
import 'dashed_rect_painter.dart';

class EmptyWalletCard extends StatelessWidget {
  const EmptyWalletCard({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        // 1. PinProvider를 읽어옵니다.
        final pinProvider = context.read<PinProvider>();
        
        // 2. PIN 등록 여부를 확인합니다. 
        // (참고: PinProvider에 해당 상태가 구현되어 있어야 합니다.)
        // 만약 아직 구현 전이라면 임시로 true/false를 넣어 테스트해보세요.
        final bool hasPin = pinProvider.status != PinStatus.idle; 

        // 3. 상태에 따라 모드를 결정하여 이동합니다.
        // 2. PIN 화면으로 이동하고 결과를 기다립니다.
        final bool? isAuthenticated = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => PinScreen(
              mode: hasPin ? PinMode.auth : PinMode.create,
            ),
          ),
        );

        // 3. PIN 인증/생성이 성공적으로 완료되었다면?
        if (isAuthenticated == true && context.mounted) {
          // [기획 반영] 실제 은행 선택 및 계좌 연동 페이지로 이동합니다.
          Navigator.push(
            context,
            MaterialPageRoute(
              // 팀장님이 만드신 은행 선택 화면(예: BankSelectionView)으로 연결하세요!
              builder: (context) => const BankSelectionView(), 
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(24),
      child: CustomPaint(
        painter: DashedRectPainter(color: AppColors.exampleFont),
        child: SizedBox(
          width: double.infinity,
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_circle_outline,
                size: 48,
                color: AppColors.mainBlue,
              ),
              const SizedBox(height: 12),
              Text(
                'Link your bank account',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.abledFont,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
