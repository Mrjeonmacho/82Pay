import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/scan_provider.dart';
import '../../transfer/views/account_input_screen.dart';

class ScanLoadingScreen extends StatefulWidget {
  final File imageFile;

  const ScanLoadingScreen({super.key, required this.imageFile});

  @override
  State<ScanLoadingScreen> createState() => _ScanLoadingScreenState();
}

class _ScanLoadingScreenState extends State<ScanLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _progressAnimation = Tween<double>(begin: 0.18, end: 0.84).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _process();
    });
  }

  Future<void> _process() async {
    final provider = context.read<ScanProvider>();

    await provider.processImage(widget.imageFile);

    if (!mounted) return;

    final result = provider.result;

    if (result != null && result.success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AccountInputScreen(
            initialBankName: result.bankName,
            initialAccountNumber: result.accountNumber,
            scanFailed: false,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AccountInputScreen(scanFailed: true),
        ),
      );
    }

    provider.reset();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double _clamp(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        final topGradientHeight = _clamp(height * 0.28, 180, 260);
        final bottomGradientHeight = _clamp(height * 0.32, 200, 300);
        final pagePaddingH = _clamp(width * 0.055, 16, 24);
        final pagePaddingV = _clamp(height * 0.022, 14, 20);

        final titleFontSize = _clamp(width * 0.08, 26, 32);
        final descFontSize = _clamp(width * 0.04, 14, 16);

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // 배경 이미지
              Positioned.fill(
                child: Container(
                  color: Colors.black,
                  alignment: Alignment.center,
                  child: Image.file(
                    widget.imageFile,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),

              // 기본 어두운 오버레이
              Positioned.fill(
                child: Container(color: Colors.black.withOpacity(0.48)),
              ),

              // 상단 그라데이션
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Container(
                    height: topGradientHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.38),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 하단 그라데이션
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: Container(
                    height: bottomGradientHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.22),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: pagePaddingH,
                    vertical: pagePaddingV,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LoadingHeader(
                        titleFontSize: titleFontSize,
                        descFontSize: descFontSize,
                      ),
                      const Spacer(),
                      _LoadingCard(
                        fadeAnimation: _fadeAnimation,
                        progressAnimation: _progressAnimation,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LoadingHeader extends StatelessWidget {
  final double titleFontSize;
  final double descFontSize;

  const _LoadingHeader({
    required this.titleFontSize,
    required this.descFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'scan_loading.scanning'.tr(),
          style: AppTextStyles.headlineLarge.copyWith(
            color: Colors.white,
            fontSize: titleFontSize,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: (descFontSize * 0.5).clamp(6, 10)),
        Text(
          'scan_loading.analyzing_image_desc'.tr(),
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white.withOpacity(0.84),
            height: 1.45,
            fontSize: descFontSize,
          ),
        ),
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<double> progressAnimation;

  const _LoadingCard({
    required this.fadeAnimation,
    required this.progressAnimation,
  });

  double _clamp(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final cardPaddingH = _clamp(width * 0.05, 16, 20);
    final cardPaddingTop = _clamp(width * 0.05, 16, 20);
    final cardPaddingBottom = _clamp(width * 0.045, 14, 18);
    final cardRadius = _clamp(width * 0.075, 24, 30);

    final iconBoxSize = _clamp(width * 0.10, 36, 42);
    final iconSize = _clamp(width * 0.055, 20, 22);
    final titleFontSize = _clamp(width * 0.047, 16, 18);
    final descFontSize = _clamp(width * 0.036, 13, 14);
    final miniFontSize = _clamp(width * 0.033, 12, 13);
    final progressHeight = _clamp(width * 0.022, 8, 10);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        cardPaddingH,
        cardPaddingTop,
        cardPaddingH,
        cardPaddingBottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FadeTransition(
                opacity: fadeAnimation,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.mainBlue.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(
                      _clamp(iconBoxSize * 0.30, 10, 12),
                    ),
                  ),
                  child: Icon(
                    Icons.document_scanner_outlined,
                    color: AppColors.mainBlue,
                    size: iconSize,
                  ),
                ),
              ),
              SizedBox(width: _clamp(width * 0.03, 10, 12)),
              Expanded(
                child: Text(
                  'scan_loading.scanning_account_info'.tr(),
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.logo,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: _clamp(width * 0.035, 12, 14)),
          Text(
            'scan_loading.scanning_account_desc'.tr(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.abledFont,
              height: 1.45,
              fontSize: descFontSize,
            ),
          ),
          SizedBox(height: _clamp(width * 0.045, 14, 18)),
          AnimatedBuilder(
            animation: progressAnimation,
            builder: (context, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 9,
                  value: progressAnimation.value,
                  backgroundColor: const Color(0xFFE8EDF6),
                  valueColor: const AlwaysStoppedAnimation(AppColors.mainBlue),
                ),
              );
            },
          ),
          SizedBox(height: _clamp(width * 0.035, 12, 14)),
          Row(
            children: [
              FadeTransition(
                opacity: fadeAnimation,
                child: Container(
                  width: _clamp(width * 0.02, 7, 8),
                  height: _clamp(width * 0.02, 7, 8),
                  decoration: const BoxDecoration(
                    color: AppColors.mainBlue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              SizedBox(width: _clamp(width * 0.02, 7, 8)),
              Expanded(
                child: Text(
                  'scan_loading.may_take_a_few_seconds'.tr(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.abledFont,
                    fontSize: miniFontSize,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
