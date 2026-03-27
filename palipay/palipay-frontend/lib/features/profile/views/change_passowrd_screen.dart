import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../providers/profile_provider.dart';
import '../../user/views/login_screen.dart';
import '../../../core/widgets/pali_button.dart';

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

  bool _oldTouched = false;
  bool _newTouched = false;
  bool _confirmTouched = false;

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
   // [추가] 에러가 하나도 없는지 확인하는 함수
  bool _hasNoErrors() {
    return _oldPasswordError == null &&
        _newPasswordError == null &&
        _confirmPasswordError == null;
  }
  void _validateFields({bool forceAll = false}) {
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    setState(() {
      _oldPasswordError = null;
      _newPasswordError = null;
      _confirmPasswordError = null;

      // 현재 비밀번호
      if (forceAll || _oldTouched) {
        if (oldPassword.isEmpty) {
          _oldPasswordError = 'profile.password.error_empty_current'.tr();
        }
      }

      // 새 비밀번호
      if (forceAll || _newTouched) {
        if (newPassword.isEmpty) {
          _newPasswordError = 'profile.password.error_empty_new'.tr();
        } else if (newPassword.length < 8) {
          _newPasswordError = 'profile.password.error_too_short'.tr();
        } else if (newPassword == oldPassword && oldPassword.isNotEmpty) {
          _newPasswordError = 'profile.password.error_same_as_current'.tr();
        }
      }

      // 새 비밀번호 확인
      if (forceAll || _confirmTouched) {
        if (confirmPassword.isEmpty) {
          _confirmPasswordError = 'profile.password.error_empty_confirm'.tr();
        } else if (confirmPassword != newPassword) {
          _confirmPasswordError = 'profile.password.error_mismatch'.tr();
        }
      }
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _oldTouched = true;
      _newTouched = true;
      _confirmTouched = true;
    });
    _validateFields(forceAll: true);

    if (!_hasNoErrors()) return;

    final provider = context.read<ProfileProvider>();

    final success = await provider.changePassword(
      oldPassword: _oldPasswordController.text.trim(),
      newPassword: _newPasswordController.text.trim(),
      confirmPassword: _confirmPasswordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(showPasswordChangedMessage: true),
        ),
        (route) => false,
      );
    } else {
      setState(() {
        _oldPasswordError = 'profile.password.error_failed'.tr();
      });
    }
  }

  Widget _buildVisibilityIcon({
    required bool obscure,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        obscure ? Icons.visibility_off : Icons.visibility,
        color: AppColors.exampleFont,
      ),
    );
  }

  Widget _buildErrorText(String? errorText) {
    if (errorText == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 2),
      child: Text(
        errorText,
        softWrap: true,
        style: const TextStyle(
          color: AppColors.warningRed,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    final size = MediaQuery.of(context).size;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = bottomInset > 0;

    final horizontalPadding = size.width * 0.064; // 24 정도
    final topPadding = size.height * 0.03;
    final fieldTopGap = size.height * 0.012;
    final sectionGap = size.height * 0.024;
    final contentBottomPadding = size.height * 0.04;

    return Scaffold(
      appBar: PaliTopBar(
        title: 'profile.password.title_change'.tr(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Password
              Text(
                'profile.password.label_current'.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              PaliInputField(
                hintText: 'profile.password.hint_current'.tr(),
                controller: _oldPasswordController,
                maxLength: 50,
                showCounter: true,
                // [선택] maxLength 빨간 강조 쓰고 싶으면 true 유지
                highlightMaxLength: true,
                isPassword: _obscureOldPassword,
                useExternalErrorText: true,
                errorText: _oldPasswordError,
                onChanged: (_) {
                  // [수정] 현재 비밀번호 필드 touched 처리
                  _oldTouched = true;
                  _validateFields();
                },
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

              // New Password
              Text(
                'profile.password.label_new'.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              PaliInputField(
                hintText: 'profile.password.hint_new'.tr(),
                controller: _newPasswordController,
                maxLength: 50,
                showCounter: true,
                highlightMaxLength: true,
                isPassword: _obscureNewPassword,
                useExternalErrorText: true,
                errorText: _newPasswordError,
                onChanged: (_) {
                  // [수정] 여기 _oldTouched 아님!
                  _newTouched = true;
                  _validateFields();
                },
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

              // Confirm New Password
              Text(
                'profile.password.label_confirm'.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              PaliInputField(
                hintText: 'profile.password.hint_confirm'.tr(),
                controller: _confirmPasswordController,
                maxLength: 50,
                showCounter: true,
                highlightMaxLength: true,
                isPassword: _obscureConfirmPassword,
                useExternalErrorText: true,
                errorText: _confirmPasswordError,
                onChanged: (_) {
                  // [수정] 여기 _oldTouched 아님!
                  _confirmTouched = true;
                  _validateFields();
                },
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

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: PaliButton(
                  text: 'profile.password.btn_change'.tr(),
                  onPressed: provider.isLoading ? null : _submit,
                  backgroundColor: AppColors.mainBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
