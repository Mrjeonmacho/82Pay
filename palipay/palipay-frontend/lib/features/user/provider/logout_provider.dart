import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LogoutProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _service.logout();

    _isLoading = false;
    notifyListeners();
  }
}