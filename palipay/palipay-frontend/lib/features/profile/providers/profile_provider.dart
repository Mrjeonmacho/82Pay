import 'package:flutter/material.dart';
import '../models/profile_user_model.dart';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _service = ProfileService();

  ProfileUserModel? _user;

  ProfileUserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isChangingPassword = false;
  bool get isChangingPassword => _isChangingPassword;

  /// 프로필 조회
  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _service.getProfile();
    } catch (e) {
      debugPrint(e.toString());
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 언어 변경
  Future<void> changeLanguage(String language) async {
    try {
      await _service.updateLanguage(language);

      if (_user != null) {
        _user = ProfileUserModel(
          name: _user!.name,
          email: _user!.email,
          language: language,
        );

        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    try {
      await _service.logout();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// 회원탈퇴
  Future<void> deleteAccount() async {
    try {
      await _service.deleteAccount();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

   /// 비밀번호 변경
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isChangingPassword = true;
    notifyListeners();

    try {
      await _service.changePassword(
        currentPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      return true;
    } catch (e) {
      debugPrint('비밀번호 변경 실패: $e');
      return false;
    } finally {
      _isChangingPassword = false;
      notifyListeners();
    }
  }
}