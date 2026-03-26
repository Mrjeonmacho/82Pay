import 'dart:async';
import 'package:flutter/material.dart';
import '../services/bank_service.dart';

class BankProvider with ChangeNotifier {
  final BankService _service = BankService();
  Timer? _timer;

  Map<String, dynamic>? _accountData;
  List<dynamic> _historyList = [];
  bool _isLoading = true; // 처음엔 true
  String _userCountry = "US";
  int _listKey = 0;

  Map<String, dynamic>? get accountData => _accountData;
  List<dynamic> get historyList => _historyList;
  bool get isLoading => _isLoading;
  String get userCountry => _userCountry;
  int get listKey => _listKey;

  // 로그인 성공 시 반드시 호출해야 함
  Future<void> init(int userId, String country) async {
    _isLoading = true;
    _userCountry = country;
    notifyListeners();

    try {
      await refreshData(userId);
    } catch (e) {
      print("데이터 초기화 에러: $e");
    } finally {
      _isLoading = false; // 여기서 로딩이 꺼짐
      notifyListeners();
    }

    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => refreshData(userId),
    );
  }

  Future<void> refreshData(int userId) async {
    String currency = (_userCountry == "KR")
        ? "KRW"
        : (_userCountry == "JP" ? "JPY" : "USD");

    // 병렬 호출로 속도 최적화
    final results = await Future.wait([
      _service.getAccountInfo(userId, currency),
      _service.getHistory(userId, currency),
    ]);

    _accountData = results[0] as Map<String, dynamic>?;

    List<dynamic> newHistory = results[1] as List<dynamic>;
    if (newHistory.length > _historyList.length) {
      _listKey++;
    }
    _historyList = newHistory;

    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
