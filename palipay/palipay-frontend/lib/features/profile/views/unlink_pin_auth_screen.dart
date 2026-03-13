import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';

class UnlinkPinAuthView extends StatefulWidget {
  const UnlinkPinAuthView({super.key});

  @override
  State<UnlinkPinAuthView> createState() => _UnlinkPinAuthViewState();
}

class _UnlinkPinAuthViewState extends State<UnlinkPinAuthView> {
  String _inputPin = '';
  String? _errorMessage;
  bool _isLoading = false;

  void _onKeyTap(String value) {
    if (_isLoading) return;

    if (_inputPin.length < 6) {
      setState(() {
        _inputPin += value;
        _errorMessage = null;
      });

      if (_inputPin.length == 6) {
        _handleComplete();
      }
    }
  }

  void _onBackspace() {
    if (_isLoading) return;

    if (_inputPin.isNotEmpty) {
      setState(() {
        _inputPin = _inputPin.substring(0, _inputPin.length - 1);
        _errorMessage = null;
      });
    }
  }

  Future<void> _handleComplete() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    // 테스트용 더미 PIN
    if (_inputPin == '123456') {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _isLoading = false;
        _inputPin = '';
        _errorMessage = 'Invalid PIN. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PaliTopBar(title: 'Verify PIN'),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Text(
              'Verify Your PIN',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.mainBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Enter your PIN to remove the linked account',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) => _buildDot(index)),
            ),

            const SizedBox(height: 20),

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.warningRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            if (_isLoading) ...[
              const SizedBox(height: 20),
              const CircularProgressIndicator(color: AppColors.mainBlue),
            ],

            const Spacer(),
            _buildKeypad(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    final isFilled = index < _inputPin.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFilled ? AppColors.mainBlue : Colors.white,
        border: Border.all(
          color: isFilled ? AppColors.mainBlue : Colors.grey.shade300,
          width: 2,
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 1.5,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          ...['1', '2', '3', '4', '5', '6', '7', '8', '9']
              .map((val) => _keyButton(val)),
          const SizedBox(),
          _keyButton('0'),
          _backspaceButton(),
        ],
      ),
    );
  }

  Widget _keyButton(String val) {
    return InkWell(
      onTap: () => _onKeyTap(val),
      child: Center(
        child: Text(
          val,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _backspaceButton() {
    return IconButton(
      onPressed: _onBackspace,
      icon: const Icon(Icons.backspace_outlined, size: 28),
    );
  }
}