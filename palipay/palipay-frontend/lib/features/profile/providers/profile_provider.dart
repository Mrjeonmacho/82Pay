import 'package:flutter/material.dart';
import '../models/profile_user_model.dart';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _service = ProfileService();

  ProfileUserModel? _user;
  ProfileUserModel? get user => _user;

  // 💡 [추가] 위젯에서 쉽게 꺼내 쓸 수 있도록 게터 추가
  String get userName => _user?.name ?? 'Guest User';
  String get userEmail => _user?.email ?? 'Please login';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isChangingPassword = false;
  bool get isChangingPassword => _isChangingPassword;

  /// 💡 [변경] API 호출 대신, 로그인 응답 데이터를 주입받음
  void setUser(ProfileUserModel user) {
    _user = user;
    notifyListeners();
  }

  /// 💡 [변경] 이제 서버에 물어볼 필요가 없으므로 fetchProfile은 주입된 데이터를 확인하는 용도로만 씁니다.
  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();

    // 더 이상 _service.getProfile()을 호출하지 않습니다.
    if (_user != null) {
      print("✅ 프로필 데이터 확인됨: ${_user!.name}");
    } else {
      print("⚠️ 주입된 프로필 데이터가 없습니다.");
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
          userId: _user!.userId,
          name: _user!.name,
          email: _user!.email,
          countryCode: _user!.countryCode,
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
