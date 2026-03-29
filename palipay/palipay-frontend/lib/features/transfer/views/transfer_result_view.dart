// lib/features/transfer/views/transfer_result_view.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // 날짜 및 금액 포맷팅용
import 'package:palipay_app/core/utils/currency_input_formatter.dart';
import 'package:palipay_app/core/theme/app_colors.dart';
import 'package:palipay_app/core/theme/app_text_styles.dart';
import 'package:palipay_app/core/widgets/pali_button.dart';
import 'package:palipay_app/features/wallet/providers/wallet_provider.dart';

class TransferResultView extends StatefulWidget {
  final String recipientName;
  final String bankName; // 🚀 [추가] 은행 이름 필수화
  final int amount;

  const TransferResultView({
    super.key,
    required this.recipientName,
    required this.bankName, // 🚀 이게 빠져있으면 여기서 빨간줄!
    required this.amount,
  });

  @override
  State<TransferResultView> createState() => _TransferResultViewState();
}

class _TransferResultViewState extends State<TransferResultView> {
  final TextEditingController _memoController = TextEditingController();

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 포맷팅 처리를 위한 변수들
    final walletProvider = context.read<WalletProvider>();
    final String senderName = walletProvider.accountUsername ?? "나의 지갑";
    final String formattedAmount = CurrencyInputFormatter.format(widget.amount);
    final dateFormat = DateFormat('yyyy.MM.dd HH:mm');
    final now = DateTime.now();
    // 가짜 거래 ID 생성
    final transactionId =
        'TPN-${now.millisecondsSinceEpoch.toString().substring(7)}';

    return Scaffold(
      // 시안 #4처럼 배경색을 아주 옅은 회색으로 설정하여 영수증 카드를 돋보이게 함
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // 백버튼 숨김
        actions: [
          // 시안 #4 상단 Close 버튼
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 1. 성공 체크 아이콘 및 헤더 (시안 #4 스타일)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9), // 옅은 녹색 배경
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 40,
                    color: Color(0xFF4CAF50), // 진한 녹색 체크
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'transfer_result.payment_complete'.tr(),
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'transfer_result.payment_amount'.tr(),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.disabledFont,
                ),
              ),
              const SizedBox(height: 8),
              // 금액 강조 (시안 #4처럼 진한 파란색 대형 폰트)
              Text(
                'transfer_confirm.amount_krw'.tr(
                  namedArgs: {'amount': formattedAmount},
                ),
                style: AppTextStyles.titleLarge.copyWith(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mainBlue,
                ),
              ),

              const SizedBox(height: 40),

              // 2. 영수증 상세 카드 영역 (시안 #4 핵심 스타일)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 수취인 정보 (아이콘 포함)
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFE8EAF6),
                          child: Icon(
                            Icons.storefront,
                            color: Color(0xFF3F51B5),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'To ',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      widget.recipientName.isNotEmpty
                                          ? widget.recipientName
                                          : 'common.unknown'.tr(),
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
                    const SizedBox(height: 20),

                    // 상세 항목들 (Row 스타일)
                    _buildReceiptRow(
                      'transfer.result.sender'.tr(),
                      senderName,
                    ), // 가짜 보낸이
                    _buildReceiptRow(
                      'transfer.result.transaction_date'.tr(),
                      dateFormat.format(now),
                    ),
                    _buildReceiptRow(
                      'transfer.result.transaction_id'.tr(),
                      transactionId,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 3. [제안 UX] 메모 입력 필드 (와이어프레임 #2 반영)
              TextField(
                controller: _memoController,
                maxLength: 20, // 짧은 메모 유도
                decoration: InputDecoration(
                  hintText: 'transfer.result.memo_hint'.tr(),
                  prefixIcon: const Icon(Icons.edit_note, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  counterText: "", // 글자수 제한 안보이게
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      // 4. 하단 고정 버튼
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: PaliButton(
          text: 'transfer.result.btn_back_home'.tr(),
          backgroundColor: const Color(0xFF0D1B63), // 시안의 진한 파란색
          onPressed: () {
            // 메모 저장 로직이 필요하다면 여기서 처리 (예: provider 호출)
            if (_memoController.text.isNotEmpty) {
              print("메모 저장: ${_memoController.text}");
            }
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ),
    );
  }

  // 영수증 상세 항목을 그리는 보조 위젯
  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
