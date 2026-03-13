import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/pali_button.dart';
import '../../../core/widgets/pali_input_field.dart';
import '../../../core/widgets/widgets.dart';
import '../providers/profile_provider.dart';
import '../../user/views/login_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  String? _oldPasswordError;
  String? _newPasswordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateFields() {
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    setState(() {
      _oldPasswordError = null;
      _newPasswordError = null;
      _confirmPasswordError = null;

      if (oldPassword.isEmpty) {
        _oldPasswordError = 'Please enter your current password.';
      }

      if (newPassword.isEmpty) {
        _newPasswordError = 'Please enter a new password.';
      } else if (newPassword.length < 8) {
        _newPasswordError = 'Password must be at least 8 characters.';
      } else if (newPassword == oldPassword) {
        _newPasswordError =
            'New password must be different from the current password.';
      }

      if (confirmPassword.isEmpty) {
        _confirmPasswordError = 'Please confirm your new password.';
      } else if (confirmPassword != newPassword) {
        _confirmPasswordError = 'Passwords do not match.';
      }
    });
  }

  bool _hasNoErrors() {
    return _oldPasswordError == null &&
        _newPasswordError == null &&
        _confirmPasswordError == null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    _validateFields();

    if (!_hasNoErrors()) return;

    final provider = context.read<ProfileProvider>();

    final success = await provider.changePassword(
      oldPassword: _oldPasswordController.text.trim(),
      newPassword: _newPasswordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(
            showPasswordChangedMessage: true,
          ),
        ),
        (route) => false,
      );
    } else {
      setState(() {
        _oldPasswordError = 'Failed to change password. Please try again.';
      });
    }
  }

  Widget _buildVisibilityIcon({
    required bool obscure,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      splashRadius: 18,
      icon: Icon(
        obscure ? Icons.visibility_off : Icons.visibility,
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: const PaliTopBar(
        title: 'Change Password',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Password',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 10),
              PaliInputField(
                hintText: 'Enter your current password',
                controller: _oldPasswordController,
                isPassword: _obscureOldPassword,
                onChanged: (_) => _validateFields(),
                errorText: _oldPasswordError,
                useExternalErrorText: true,
                suffixIcon: _buildVisibilityIcon(
                  obscure: _obscureOldPassword,
                  onPressed: () {
                    setState(() {
                      _obscureOldPassword = !_obscureOldPassword;
                    });
                  },
                ),
              ),
              _buildErrorText(_oldPasswordError),

              const SizedBox(height: 20),

              Text(
                'New Password',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 10),
              PaliInputField(
                hintText: 'Enter your new password',
                controller: _newPasswordController,
                isPassword: _obscureNewPassword,
                onChanged: (_) => _validateFields(),
                errorText: _newPasswordError,
                useExternalErrorText: true,
                suffixIcon: _buildVisibilityIcon(
                  obscure: _obscureNewPassword,
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
              ),
              _buildErrorText(_newPasswordError),

              const SizedBox(height: 20),

              Text(
                'Confirm New Password',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 10),
              PaliInputField(
                hintText: 'Confirm your new password',
                controller: _confirmPasswordController,
                isPassword: _obscureConfirmPassword,
                onChanged: (_) => _validateFields(),
                errorText: _confirmPasswordError,
                useExternalErrorText: true,
                suffixIcon: _buildVisibilityIcon(
                  obscure: _obscureConfirmPassword,
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              _buildErrorText(_confirmPasswordError),

              const SizedBox(height: 36),

              provider.isChangingPassword
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : PaliButton(
                      text: 'Change Password',
                      onPressed: _submit,
                      backgroundColor: AppColors.mainBlue,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}