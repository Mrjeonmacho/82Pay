import 'dart:async';
import 'package:flutter/material.dart';
import '../services/bank_service.dart';

class BankProvider with ChangeNotifier {
  final BankService _service = BankService();

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
  }

  Future<void> refreshData(int userId) async {
    String currency = "USD"; // 기본값
    if (_userCountry == "KR") {
      currency = "KRW";
    } else if (_userCountry == "JP") {
      currency = "JPY";
    } else if (_userCountry == "CN") {
      currency = "CNY"; // 👈 중국 위안화 추가
    }

    // 병렬 호출로 속도 최적화
    try {
      final results = await Future.wait([
        _service.getAccountInfo(userId, currency),
        _service.getHistory(userId, currency),
      ]);

      _accountData = results[0] as Map<String, dynamic>?;

      List<dynamic> newHistory = (results[1] as List<dynamic>?) ?? [];

      // 2. 번쩍거림 방지 로직
      // 데이터가 하나라도 새로 들어왔거나(개수 변화), 첫 데이터의 ID가 달라졌을 때만 listKey 변경
      if (_historyList.length != newHistory.length) {
        _listKey++;
      }

      _historyList = newHistory;
      notifyListeners();
    } catch (e) {
      print("Refresh Error: $e");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
