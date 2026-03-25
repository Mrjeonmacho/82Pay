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
  Future<void> fetchHistory({int page = 0, String? category, int? walletId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _service.getTransactions(
        page: page,
        category: category,
        walletId: walletId,
      );
      _items = (data['items'] as List)
          .map((e) => Transaction.fromJson(e))
          .toList();
    } catch (e) {
      debugPrint('Error fetching history: $e');
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
