import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../provider/delete_account_provider.dart';
import 'login_screen.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String? _passwordError;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _validateField() {
    final password = _passwordController.text.trim();

    setState(() {
      _passwordError = null;

      if (password.isEmpty) {
        _passwordError = 'profile.delete_account.error_empty_password'.tr();
      }
    });
  }

  bool _hasNoErrors() {
    return _passwordError == null;
  }

  Widget _buildVisibilityIcon() {
    return IconButton(
      onPressed: () {
        setState(() {
          _obscurePassword = !_obscurePassword;
        });
      },
      splashRadius: 18,
      icon: Icon(
        _obscurePassword ? Icons.visibility_off : Icons.visibility,
        size: 20,
        color: AppColors.exampleFont,
      ),
    );
  }

  Widget _buildErrorText(String? errorText) {
    if (errorText == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 6),
      child: Text(
        errorText,
        softWrap: true,
        style: const TextStyle(
          color: AppColors.warningRed,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.3,
        ),
      ),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    _validateField();

    if (!_hasNoErrors()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<DeleteAccountProvider>();
      final result = await provider.deleteAccount(
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      switch (result) {
        case DeleteAccountResult.invalidPassword:
          setState(() {
            _passwordError = 'profile.delete_account.error_failed'.tr();
          });
          break;

        case DeleteAccountResult.remainingBalance:
          await _showRemainingBalanceDialog();
          break;

        case DeleteAccountResult.success:
          await _showDeleteSuccessDialog();
          _moveToLoginScreen();
          break;

        case DeleteAccountResult.failure:
          await _showFailureDialog();
          break;
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showRemainingBalanceDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          content: Text(
            'profile.delete_account.dialog_remaining_balance'.tr(),
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: PaliButton(
                text: 'common.ok'.tr(),
                onPressed: () {
                  Navigator.pop(context);
                },
                backgroundColor: AppColors.mainBlue,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteSuccessDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          content: Text(
            'profile.delete_account.dialog_success'.tr(),
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: PaliButton(
                text: 'common.ok'.tr(),
                onPressed: () {
                  Navigator.pop(context);
                },
                backgroundColor: AppColors.mainBlue,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showFailureDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          content: Text(
            'profile.delete_account.dialog_failure'.tr(),
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: PaliButton(
                text: 'common.ok'.tr(),
                onPressed: () {
                  Navigator.pop(context);
                },
                backgroundColor: AppColors.mainBlue,
              ),
            ),
          ],
        );
      },
    );
  }

  void _moveToLoginScreen() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: PaliTopBar(
        title: 'profile.delete_account.title'.tr(),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                const Center(
                  child: Icon(
                    Icons.error_outline,
                    size: 120,
                    color: AppColors.warningRed,
                  ),
                ),

                const SizedBox(height: 32),

                Text(
                  'profile.delete_account.description'.tr(),
                  style: AppTextStyles.bodyMedium,
                ),

                const SizedBox(height: 28),

                Text(
                  'profile.delete_account.label_password'.tr(),
                  style: AppTextStyles.bodyMedium,
                ),

                const SizedBox(height: 10),

                PaliInputField(
                  hintText: 'profile.delete_account.hint_password'.tr(),
                  controller: _passwordController,
                  isPassword: _obscurePassword,
                  onChanged: (_) => _validateField(),
                  errorText: _passwordError,
                  useExternalErrorText: true,
                  suffixIcon: _buildVisibilityIcon(),
                ),

                _buildErrorText(_passwordError),

                const SizedBox(height: 36),

                _isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : PaliButton(
                        text: 'profile.delete_account.button'.tr(),
                        onPressed: _submit,
                        backgroundColor: AppColors.mainBlue,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}