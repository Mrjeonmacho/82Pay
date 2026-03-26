import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/wallet_model.dart';
import '../services/wallet_service.dart';

enum WalletStatus { idle, loading, success, failure }

class WalletProvider extends ChangeNotifier {
  final WalletService _service = WalletService();

  WalletStatus status = WalletStatus.idle;
  WalletBalanceModel wallet = WalletBalanceModel.empty();

  double _krwAmount = 0;
  double _foreignAmount = 0;
  double _exchangeRate = 0;
  String _targetCurrency = "USD";
  String? _quoteId;
  String? _rateTimestamp;
  String? _errorMessage;
  int? _maxRefundableAmount;
  bool _isTopupView = false;

  // --- [1] Getters ---
  int? get balance => wallet.currentBalance;
  int? get currentBalance => wallet.currentBalance;
  String? get rateTimestamp => _rateTimestamp;
  double get krwAmount => _krwAmount;
  double get foreignAmount => _foreignAmount;
  double get exchangeRate => _exchangeRate;
  String get targetCurrency => _targetCurrency;
  String? get errorMessage => _errorMessage;
  int? get maxRefundableAmount => _maxRefundableAmount;
  bool get isLoading => status == WalletStatus.loading;

  // --- [2] 초기화 로직 ---
  Future<void> initWalletData() async => await loadWalletBalance(walletId: 1);
  void initForTopup({String? currency}) => initForAction(isTopup: true, currency: currency ?? "USD");
  void initForRefund({String? currency}) => initForAction(isTopup: false, currency: currency ?? "USD");

  void initForAction({required bool isTopup, required String currency}) {
    _isTopupView = isTopup;
    _targetCurrency = currency;
    _krwAmount = 0;
    _foreignAmount = 0;
    _errorMessage = null;
    notifyListeners();
  }

  // --- [3] API 연동 메서드 ---

  /// 실시간 환율 견적 조회 (이 메서드가 없어서 에러가 났었습니다!)
  Future<void> loadExchangeRateQuote() async {
    try {
      final response = await _service.getExchangeRateQuote(currency: _targetCurrency);
      final data = response['data'];
      if (data != null) {
        _exchangeRate = (data['exchangeRate'] as num).toDouble();
        _quoteId = data['quoteId'];
        _rateTimestamp = data['rateTimestamp'];
        
        // 환율이 갱신되면 입력된 금액도 재계산
        if (_krwAmount > 0) updateKrwAmount(_krwAmount);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('🚨 환율 로드 실패: $e');
    }
  }

  /// 지갑 잔액 조회
  Future<void> loadWalletBalance({required int walletId, num? amount, String? accessToken}) async {
    status = WalletStatus.loading;
    notifyListeners();
    try {
      wallet = await _service.fetchWalletBalance(walletId: walletId, amount: amount ?? 0);
      status = WalletStatus.success;
    } catch (e) {
      status = WalletStatus.failure;
    }
    notifyListeners();
  }

  /// 최대 환불 가능 금액 조회
  Future<void> loadMaxRefundable(int walletId) async {
    try {
      final response = await _service.getMaxRefundable(walletId: walletId);
      final data = response['data'];
      if (data != null) {
        _maxRefundableAmount = (data['maxRefundableAmount'] as num).toInt();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('🚨 최대 환불 조회 실패: $e');
    }
  }

  // --- [4] 금액 입력 및 계산 로직 ---

  void updateKrwAmount(double amount) {
    _krwAmount = amount;
    if (_exchangeRate > 0) {
      _foreignAmount = _krwAmount / _exchangeRate;
    }
    _validateAmount();
    notifyListeners();
  }

  void updateKrwAmountFromText(String text) {
    final amount = double.tryParse(text.replaceAll(',', '')) ?? 0;
    updateKrwAmount(amount);
  }

  void addQuickAmount(double amount) => updateKrwAmount(_krwAmount + amount);

  void _validateAmount() {
    if (!_isTopupView && currentBalance != null && _krwAmount > currentBalance!) {
      _errorMessage = 'wallet.error.insufficient_balance'.tr();
    } else if (_krwAmount > 2000000) {
      _errorMessage = 'wallet.error.max_limit'.tr();
    } else {
      _errorMessage = null;
    }
  }

  // --- [5] 트랜잭션 실행 (충전/환급) ---

  Future<bool> chargeWallet({required int walletId, required String pinNumber}) async {
    return await _executeTransaction(
      walletId: walletId,
      pinNumber: pinNumber,
      action: (wid, pin) => _service.chargeWallet(
        walletId: wid,
        pinNumber: pin,
        accountCurrency: _targetCurrency,
        convertedAmount: _krwAmount,
        amount: _foreignAmount,
      ),
      errorMsg: '충전에 실패했습니다.',
    );
  }

  Future<bool> refundWallet({required int walletId, required String pinNumber}) async {
    return await _executeTransaction(
      walletId: walletId,
      pinNumber: pinNumber,
      action: (wid, pin) => _service.refundWallet(
        walletId: wid,
        pinNumber: pin,
        accountCurrency: _targetCurrency,
        convertedAmount: _krwAmount,
        amount: _foreignAmount,
      ),
      errorMsg: '환급에 실패했습니다.',
    );
  }

  Future<bool> _executeTransaction({
    required int walletId,
    required String pinNumber,
    required Future<dynamic> Function(int, String) action,
    required String errorMsg,
  }) async {
    status = WalletStatus.loading;
    notifyListeners();
    try {
      final response = await action(walletId, pinNumber);
      final data = response['data'];
      if (data != null && data['currentBalance'] != null) {
        wallet = wallet.copyWith(currentBalance: (data['currentBalance'] as num).toInt());
      }
      status = WalletStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      status = WalletStatus.failure;
      _errorMessage = errorMsg;
      notifyListeners();
      return false;
    }
  }
}