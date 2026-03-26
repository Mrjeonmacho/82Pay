// lib/features/history/providers/history_provider.dart

import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/history_service.dart';

class HistoryProvider with ChangeNotifier {
  final HistoryService _service = HistoryService();
  List<Transaction> _items = [];
  bool _isLoading = false;

  List<Transaction> get items => _items;
  bool get isLoading => _isLoading;

  /// 거래 내역 목록 조회 (필터 기능 제거됨)
  Future<void> fetchHistory({int page = 0, int? walletId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // service 호출에서도 category 파라미터 삭제
      final data = await _service.getTransactions(
        page: page,
        walletId: walletId,
      );
      
      _items = (data['items'] as List)
          .map((e) => Transaction.fromJson(e))
          .toList();
    } catch (e) {
      debugPrint('Error fetching history: $e');
      _items = []; // 에러 발생 시 리스트 초기화 혹은 에러 처리 로직 추가 가능
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 특정 거래 상세 환산 정보 조회 (이건 상세 페이지용이라 유지)
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
      debugPrint('Error fetching currency detail: $e');
      return null;
    }
  }
}