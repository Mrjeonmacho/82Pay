// lib/features/history/providers/history_provider.dart

import 'package:flutter/material.dart';
import 'package:palipay_app/features/history/models/transaction_model.dart';
import 'package:palipay_app/features/history/services/history_service.dart';

class HistoryProvider with ChangeNotifier {
  final HistoryService _service = HistoryService();
  List<Transaction> _items = [];
  bool _isLoading = false;

  List<Transaction> get items => _items;
  bool get isLoading => _isLoading;

  // 1. 거래 내역 목록 조회 (001 API)
  Future<void> fetchHistory({int page = 0, String? category}) async {
    _isLoading = true;
    notifyListeners();

    // TODO: API 연동 후 주석 제거
    // try {
    //   final data = await _service.getTransactions(
    //     page: page,
    //     category: category,
    //   );
    //   _items = (data['items'] as List)
    //       .map((e) => Transaction.fromJson(e))
    //       .toList();
    // } finally {
    //   _isLoading = false;
    //   notifyListeners();
    // }

    try {
      // --- 실제 서버 대신 목 데이터를 넣어줍니다 ---
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // 실제 통신 느낌을 위해 딜레이 추가

      final List<Transaction> mockData = [
        // 오늘 내역 (OUTPUT)
        Transaction(
          id: 9001,
          category: 'OUTPUT',
          amount: 5500,
          otherAccountName: 'Starbucks Gangnam',
          createdAt: DateTime.now(),
          description: 'Morning Coffee',
        ),
        // 오늘 내역 (INPUT)
        Transaction(
          id: 9002,
          category: 'INPUT',
          amount: 50000,
          otherAccountName: 'Wallet Top-up',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          description: 'Weekly Allowance',
        ),
        // 어제 내역 (OUTPUT)
        Transaction(
          id: 9003,
          category: 'OUTPUT',
          amount: 14500,
          otherAccountName: 'Shake Shack',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          description: 'Dinner with friends',
        ),
        // 며칠 전 내역 (OUTPUT)
        Transaction(
          id: 9004,
          category: 'OUTPUT',
          amount: 1250,
          otherAccountName: 'Public Transport',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          description: 'Bus fare',
        ),
      ];

      // 필터 로직이 잘 작동하는지 확인하기 위해 필터링 처리
      if (category == 'INPUT') {
        _items = mockData.where((e) => e.category == 'INPUT').toList();
      } else if (category == 'OUTPUT') {
        _items = mockData.where((e) => e.category == 'OUTPUT').toList();
      } else {
        _items = mockData;
      }
    } catch (e) {
      // 에러 처리 로직
      debugPrint('Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. 특정 거래 상세 환산 정보 조회 (002 API)
  Future<TransactionCurrencyDetail?> fetchCurrencyDetail(int id) async {
    try {
      final res = await _service.getTransactionCurrency(id, 'USD');
      return TransactionCurrencyDetail(
        exchangeRate: res['exchangeRate'],
        exchangedAmount: res['exchangedAmount'],
        targetCurrency: res['targetCurrency'],
        rateTimestamp: DateTime.parse(res['rateTimestamp']),
      );
    } catch (e) {
      return null;
    }
  }
}
