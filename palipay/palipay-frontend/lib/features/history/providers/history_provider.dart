import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/history_service.dart';

class HistoryProvider with ChangeNotifier {
  final HistoryService _service = HistoryService();

  List<Transaction> _items = [];
  bool _isLoading = false;

  // 🚀 페이징 처리를 위한 상태 변수
  int _currentPage = 0;
  int _totalPages = 0;
  int _totalElements = 0;

  List<Transaction> get items => _items;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalElements => _totalElements;
  bool get hasNextPage => _currentPage < _totalPages - 1;

  /// 1. 거래 내역 목록 조회 (FINANCE_HISTORY_001 반영)
  Future<void> fetchHistory({
    int page = 0,
    int? walletId,
    bool isRefresh = true,
  }) async {
    // WalletProvider에서 관리하는 walletId가 유효한지 먼저 체크
    if (walletId == null || walletId == 0) {
      debugPrint('⚠️ HistoryProvider: walletId가 유효하지 않아 조회를 취소합니다.');
      return;
    }

    _isLoading = true;
    if (isRefresh) {
      _items = [];
      _currentPage = 0;
    }
    notifyListeners();

    try {
      // 서비스 호출 (서비스에서 이미 response.data['data']를 반환한다고 가정)
      final data = await _service.getTransactions(
        page: page,
        walletId: walletId,
      );

      if (data != null) {
        // 1) 거래 목록 매핑 (data['items'] 접근)
        final List rawList = data['items'] ?? [];
        final newItems = rawList.map((e) => Transaction.fromJson(e)).toList();

        if (isRefresh) {
          _items = newItems;
        } else {
          _items.addAll(newItems);
        }

        // 2) 페이징 정보 업데이트 (data['page'] 접근)
        if (data['page'] != null) {
          final pageInfo = data['page'];
          _currentPage = pageInfo['page'] ?? 0;
          _totalPages = pageInfo['totalPages'] ?? 0;
          _totalElements = pageInfo['totalElements'] ?? 0;
        }

        debugPrint(
          '✅ 내역 로드 완료: ${_items.length}건 (Page: $_currentPage/$_totalPages)',
        );
      }
    } catch (e) {
      debugPrint('🚨 HistoryProvider fetchHistory 에러: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 2. 특정 거래 상세 환산 정보 조회 (FINANCE_HISTORY_002 반영)
  Future<TransactionCurrencyDetail?> fetchCurrencyDetail(
    int transactionId, {
    String targetCurrency = 'USD',
  }) async {
    try {
      // 서비스 호출
      final res = await _service.getTransactionCurrency(
        transactionId: transactionId,
        targetCurrency: targetCurrency,
      );

      if (res != null) {
        // 🚀 모델의 fromJson을 사용하여 명세서 필드(sourceAmount, exchangeRate 등)를 자동 매핑
        return TransactionCurrencyDetail.fromJson(res);
      }
      return null;
    } catch (e) {
      debugPrint('🚨 HistoryProvider fetchCurrencyDetail 에러: $e');
      return null;
    }
  }

  /// 계좌 연동 해제 시 히스토리 초기화
  void clearHistory() {
    _items = [];
    _currentPage = 0;
    _totalPages = 0;
    _totalElements = 0;
    notifyListeners();
  }
}
