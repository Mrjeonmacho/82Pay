import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider 임포트 추가
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/pali_bank_selection_sheet.dart';
import '../../pin/views/pin_screen.dart';
import '../../pin/providers/pin_provider.dart';
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
          // [기획 반영] 은행 선택 바텀시트를 바로 띄웁니다.
          // TODO: 유저의 국가 정보를 받아오는 로직이 있다면 'KR' 대신 변수 사용
          _openBankSelection(context, 'KR');
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

  // 은행 선택 바텀시트
  void _openBankSelection(BuildContext context, String userCountry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => BankSelectionSheet(
        countryCode: userCountry, // 'US'면 미국, 'KR'이면 한국
        onSelect: (selectedBank) {
          // 선택된 정보로 다음 화면 이동 또는 상태 업데이트
          print("선택된 은행: ${selectedBank['name']}, 코드: ${selectedBank['bankCode']}");
        },
      ),
    );
  }
}
