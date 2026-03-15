import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/pin_provider.dart';

enum ChangePinStep {
  verifyCurrentPin,
  enterNewPin,
  confirmNewPin,
  completed,
}

class ChangePinScreen extends StatefulWidget {
  final int walletId;

  const ChangePinScreen({
    super.key,
    required this.walletId,
  });

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  ChangePinStep _step = ChangePinStep.verifyCurrentPin;

  String _inputPin = "";
  String _currentPin = "";
  String _newPin = "";
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
    final pinProvider = context.read<PinProvider>();

    switch (_step) {
      case ChangePinStep.verifyCurrentPin:
        setState(() {
          _isLoading = true;
        });

        final isValid = await pinProvider.verifyPin(
          widget.walletId,
          pinNumber: _inputPin,
        );

        if (!mounted) return;

        if (isValid) {
          setState(() {
            _currentPin = _inputPin;
            _inputPin = "";
            _errorMessage = null;
            _step = ChangePinStep.enterNewPin;
            _isLoading = false;
          });
        } else {
          setState(() {
            _inputPin = "";
            _errorMessage =
                pinProvider.errorMessage ?? "The current PIN is incorrect.";
            _isLoading = false;
          });
        }
        break;

      case ChangePinStep.enterNewPin:
        if (_inputPin == _currentPin) {
          setState(() {
            _inputPin = "";
            _errorMessage =
                "Your new PIN must be different from the current PIN.";
          });
          return;
        }

        setState(() {
          _newPin = _inputPin;
          _inputPin = "";
          _errorMessage = null;
          _step = ChangePinStep.confirmNewPin;
        });
        break;

      case ChangePinStep.confirmNewPin:
        if (_inputPin != _newPin) {
          setState(() {
            _inputPin = "";
            _errorMessage = "The new PINs do not match. Please try again.";
          });
          return;
        }

        setState(() {
          _isLoading = true;
        });

        final isUpdated = await pinProvider.updatePin(
          walletId: widget.walletId,
          oldPinNumber: _currentPin,
          newPinNumber: _newPin,
        );

        if (!mounted) return;

        if (isUpdated) {
          setState(() {
            _inputPin = "";
            _errorMessage = null;
            _step = ChangePinStep.completed;
            _isLoading = false;
          });
        } else {
          setState(() {
            _inputPin = "";
            _errorMessage =
                pinProvider.errorMessage ?? "Failed to change PIN.";
            _isLoading = false;
          });
        }
        break;

      case ChangePinStep.completed:
        break;
    }
  }

  String get _title {
    switch (_step) {
      case ChangePinStep.verifyCurrentPin:
        return "Verify Current PIN";
      case ChangePinStep.enterNewPin:
        return "Create New PIN";
      case ChangePinStep.confirmNewPin:
        return "Confirm New PIN";
      case ChangePinStep.completed:
        return "PIN Changed";
    }
  }

  String get _subTitle {
    switch (_step) {
      case ChangePinStep.verifyCurrentPin:
        return "Enter your current 6-digit PIN";
      case ChangePinStep.enterNewPin:
        return "Set a new 6-digit PIN";
      case ChangePinStep.confirmNewPin:
        return "Please re-enter your new PIN";
      case ChangePinStep.completed:
        return "Your PIN has been changed successfully";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "PaliPay",
          style: TextStyle(
            color: AppColors.mainBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: AppColors.mainBlue),
      ),
      body: SafeArea(
        child: _step == ChangePinStep.completed
            ? _buildCompletedView(context)
            : _buildInputView(),
      ),
    );
  }

  Widget _buildInputView() {
    return Column(
      children: [
        const SizedBox(height: 16),

        Text(
          _title,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.mainBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        Text(
          _subTitle,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 28),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (index) => _buildDot(index)),
        ),

        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            height: 48,
            child: Center(
              child: Text(
                _errorMessage ?? '',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.warningRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        if (_isLoading)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: CircularProgressIndicator(),
          ),

        const SizedBox(height: 30),

        _buildKeypad(),

        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildCompletedView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF3FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              size: 72,
              color: AppColors.mainBlue,
            ),
          ),

          const SizedBox(height: 36),

          Text(
            _title,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.mainBlue,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            _subTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text("Done"),
            ),
          ),

          const SizedBox(height: 20),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 20,
        childAspectRatio: 1.6,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          ...[
            "1",
            "2",
            "3",
            "4",
            "5",
            "6",
            "7",
            "8",
            "9",
          ].map((val) => _keyButton(val)),
          const SizedBox(),
          _keyButton("0"),
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
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _backspaceButton() {
    return IconButton(
      onPressed: _onBackspace,
      icon: const Icon(
        Icons.backspace_outlined,
        size: 28,
        color: Colors.black54,
      ),
    );
  }
}