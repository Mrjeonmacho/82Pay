import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/scan_provider.dart';
import 'account_input_screen.dart';

class ScanLoadingScreen extends StatefulWidget {
  final File imageFile;

  const ScanLoadingScreen({
    super.key,
    required this.imageFile,
  });

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

    _fadeAnimation = Tween<double>(
      begin: 0.35,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _progressAnimation = Tween<double>(
      begin: 0.18,
      end: 0.84,
    ).animate(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.file(
              widget.imageFile,
              fit: BoxFit.cover,
            ),
          ),

          // 기본 어두운 오버레이
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.48),
            ),
          ),

          // 상단 그라데이션
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: 240,
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
                height: 280,
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
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _LoadingHeader(),
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
  }
}

class _LoadingHeader extends StatelessWidget {
  const _LoadingHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scanning',
          style: AppTextStyles.headlineLarge.copyWith(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We are analyzing the selected image\nand extracting the account details.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white.withOpacity(0.84),
            height: 1.45,
            fontSize: 15,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(30),
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
                    color: AppColors.mainBlue.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.document_scanner_outlined,
                    color: AppColors.mainBlue,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Scanning account information',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.logo,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Please wait while we recognize the bank name and account number from the image.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.abledFont,
              height: 1.45,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 18),
          AnimatedBuilder(
            animation: progressAnimation,
            builder: (context, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 9,
                  value: progressAnimation.value,
                  backgroundColor: const Color(0xFFE8EDF6),
                  valueColor: const AlwaysStoppedAnimation(
                    AppColors.mainBlue,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              FadeTransition(
                opacity: fadeAnimation,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.mainBlue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'This may take a few seconds',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.abledFont,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}