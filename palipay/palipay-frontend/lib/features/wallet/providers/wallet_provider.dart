import 'package:flutter/material.dart';
import '../models/wallet_model.dart';
import '../services/wallet_service.dart';

enum WalletStatus { idle, loading, success, failure } // 상태 관리

class WalletProvider extends ChangeNotifier {
  final WalletService _service = WalletService();

  WalletStatus status = WalletStatus.idle;
  WalletBalanceModel wallet = WalletBalanceModel.empty();

  // --- 추가된 상태 값들 (기획서 반영) ---
  double _krwAmount = 0; // 입력된 원화 금액
  double _foreignAmount = 0; // 환산된 외화 금액
  double _exchangeRate = 1472.70; // 실시간 환율 (임시)
  String _targetCurrency = "USD"; // 대상 통화

  int? get balance => wallet.currentBalance;
  String? _errorMessage; // "금액이 부족합니다" 등의 메시지

  // Getters
  int? get currentBalance => wallet.currentBalance;
  double get krwAmount => _krwAmount;
  double get foreignAmount => _foreignAmount;
  double get exchangeRate => _exchangeRate;
  String? get errorMessage => _errorMessage;
  bool get isLoading => status == WalletStatus.loading;

  // 1. 원화 기준 금액 업데이트 (퀵 버튼 누르거나 원화 입력 시)
  void updateKrwAmount(double amount) {
    _krwAmount = amount;
    // 외화 환산: 원화 / 환율
    _foreignAmount = _krwAmount / _exchangeRate;
    _validateAmount();
    notifyListeners();
  }

  void updateKrwAmountFromText(String text) {
    // 콤마 제거 후 숫자로 변환
    final cleanText = text.replaceAll(',', '');
    // 숫자로 변환 (실패 시 0)
    final amount = double.tryParse(cleanText) ?? 0;

    updateKrwAmount(amount); // 아까 만든 숫자 기반 함수 호출
  }

  // 2. 외화 기준 금액 업데이트 (외국돈 입력 시)
  void updateForeignAmount(double amount) {
    _foreignAmount = amount;
    // 원화 환산: 외화 * 환율
    _krwAmount = _foreignAmount * _exchangeRate;

    // 일본(JPY)은 정수만, 그 외는 소수점 처리 (기획서 1번 반영)
    if (_targetCurrency == "JPY") {
      _krwAmount = _krwAmount.roundToDouble();
    }
    _validateAmount();
    notifyListeners();
  }

  void updateForeignAmountFromText(String text) {
    // 외화는 소수점이 있을 수 있으므로 동일하게 처리
    final cleanText = text.replaceAll(',', '');
    final amount = double.tryParse(cleanText) ?? 0;

    updateForeignAmount(amount);
  }

  // 3. 퀵 버튼 입력 (+10, +1000 등)
  void addQuickAmount(double amount) {
    updateKrwAmount(_krwAmount + amount);
  }

  // 4. 유효성 검사 (기획서 6번: 실시간 잔액 부족 알림)
  void _validateAmount() {
    if (wallet.currentBalance != null && _krwAmount > wallet.currentBalance!) {
      _errorMessage = "금액이 부족합니다.";
    } else if (_krwAmount > 2000000) {
      _errorMessage = "최대 충전 가능 금액은 2,000,000₩ 입니다.";
    } else {
      _errorMessage = null;
    }
  }

  Future<void> loadWalletBalance({
    String? accessToken,
    required int walletId,
    required num amount,
  }) async {
    status = WalletStatus.loading;
    notifyListeners();

    try {
      /// -----------------------------------------
      /// 지금: 더미 데이터 사용
      /// -----------------------------------------
      final response = await _service.fetchWalletBalanceDummy(
        walletId: walletId,
        amount: amount,
      );

      /// -----------------------------------------
      /// 나중에 서버 연결 시 아래로 교체
      /// -----------------------------------------
      // final response = await _service.fetchWalletBalance(
      //   accessToken: accessToken ?? '',
      //   walletId: walletId,
      //   amount: amount,
      // );

      wallet = response;
      status = WalletStatus.success;
    } catch (e) {
      wallet = const WalletBalanceModel(
        currentBalance: null,
        isSufficient: null,
        requiredAmount: null,
        shortageAmount: null,
        message: 'failed to load wallet balance',
      );
      status = WalletStatus.failure;
    }

    notifyListeners();
  }
}
