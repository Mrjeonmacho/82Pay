// lib/features/wallet/providers/wallet_provider.dart

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/wallet_model.dart';
import '../services/wallet_service.dart';
import '../../../core/constants/bank_constants.dart'; // 💡 임포트 확인

enum WalletStatus { idle, loading, success, failure }

class WalletProvider extends ChangeNotifier {
  final WalletService _service = WalletService();

  // --- [1] 상태 변수 ---
  WalletStatus status = WalletStatus.idle;
  WalletBalanceModel wallet = WalletBalanceModel.empty();
  WalletInfoModel walletInfo = WalletInfoModel.empty();

  int? _walletId;
  double _krwAmount = 0;
  double _foreignAmount = 0;
  double _exchangeRate = 0;
  String _targetCurrency = "USD";
  String? _quoteId;
  String? _rateTimestamp;
  String? _errorMessage;
  bool _isTopupView = false;

  String? _bankName;
  String? _bankLogo;

  // --- [2] Getters ---
  int? get currentBalance =>
      wallet.currentBalance ?? walletInfo.amount?.toInt();
  int? get balance => currentBalance;
  int? get walletId => _walletId;
  String? get accountNumber => walletInfo.accountNumber;
  String? get accountUsername => walletInfo.accountUsername;
  double? get walletAmount => walletInfo.amount;

  double get krwAmount => _krwAmount;
  double get foreignAmount => _foreignAmount;
  double get exchangeRate => _exchangeRate;
  String? get rateTimestamp => _rateTimestamp;
  String get targetCurrency => _targetCurrency;
  String? get errorMessage => _errorMessage;
  bool get isLoading => status == WalletStatus.loading;

  String get bankName => _bankName ?? 'Unknown Bank';
  String? get bankLogo => _bankLogo;
  // 1. 마스킹된 계좌번호 게터
  String get maskedAccountNumber {
    final acc = walletInfo.accountNumber ?? "";
    if (acc.length > 4) {
      // 뒤에서 4자리만 자르고 앞에 점을 붙임
      return '•••• ${acc.substring(acc.length - 4)}';
    }
    return acc; // 4자리 이하면 그냥 노출
  }

  // --- [3] 데이터 로드 로직 ---

  Future<void> initWalletData() async {
    status = WalletStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      await loadWalletInfo();
      status = WalletStatus.success;
    } catch (e) {
      status = WalletStatus.failure;
      _errorMessage = '지갑 정보를 불러오는데 실패했습니다.';
    }
    notifyListeners();
  }

  Future<void> loadWalletInfo() async {
    try {
      // 1. 서비스로부터 bankCode가 포함된 모델을 받아옴
      walletInfo = await _service.fetchWalletInfo();

      if (walletInfo.walletId != null) {
        _walletId = walletInfo.walletId;

        // 2. 모델에 담긴 bankCode로 은행 이름/로고 찾기
        final String? code = walletInfo.bankCode;
        final bankData = BankConstants.findBankByCode(code);

        if (bankData != null) {
          _bankName = bankData['name'];
          _bankLogo = bankData['logo'];
        } else {
          _bankName = code != null ? 'Bank ($code)' : 'Unknown Bank';
          _bankLogo = null;
        }

        wallet = wallet.copyWith(currentBalance: walletInfo.amount?.toInt());
      }
      notifyListeners();
    } catch (e) {
      debugPrint('🚨 loadWalletInfo 실패: $e');
      rethrow;
    }
  }

  Future<void> loadWalletBalance({num? amount}) async {
    if (_walletId == null) return;
    try {
      wallet = await _service.fetchWalletBalance(
        walletId: _walletId!,
        amount: amount ?? 0,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('🚨 loadWalletBalance 실패: $e');
    }
  }

  Future<void> loadExchangeRateQuote() async {
    try {
      final response = await _service.getExchangeRateQuote(
        currency: _targetCurrency,
      );
      final data = response['data'];
      if (data != null) {
        _exchangeRate = (data['exchangeRate'] as num).toDouble();
        _quoteId = data['quoteId'];
        _rateTimestamp = data['rateTimestamp'];
        if (_krwAmount > 0) updateKrwAmount(_krwAmount);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('🚨 환율 로드 실패: $e');
    }
  }

  // --- [4] UI 계산 로직 ---

  void initForTopup({String? currency}) =>
      _initForAction(isTopup: true, currency: currency ?? "USD");
  void initForRefund({String? currency}) =>
      _initForAction(isTopup: false, currency: currency ?? "USD");

  void _initForAction({required bool isTopup, required String currency}) {
    _isTopupView = isTopup;
    _targetCurrency = currency;
    _krwAmount = 0;
    _foreignAmount = 0;
    _errorMessage = null;
    loadExchangeRateQuote();
    notifyListeners();
  }

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
    if (!_isTopupView &&
        currentBalance != null &&
        _krwAmount > currentBalance!) {
      _errorMessage = 'wallet.error.insufficient_balance'.tr();
    } else if (_krwAmount > 2000000) {
      _errorMessage = 'wallet.error.max_limit'.tr();
    } else {
      _errorMessage = null;
    }
  }

  // --- [5] 트랜잭션 ---

  Future<bool> chargeWallet({required String pinNumber}) async {
    if (_walletId == null) return false;
    return await _executeTransaction(
      walletId: _walletId!,
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

  Future<bool> refundWallet({required String pinNumber}) async {
    if (_walletId == null) return false;
    return await _executeTransaction(
      walletId: _walletId!,
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
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await action(walletId, pinNumber);
      final data = response['data'];
      if (data != null && data['currentBalance'] != null) {
        final newBalance = (data['currentBalance'] as num).toInt();
        wallet = wallet.copyWith(currentBalance: newBalance);
        walletInfo = walletInfo.copyWith(amount: newBalance.toDouble());
        status = WalletStatus.success;
        notifyListeners();
        return true;
      }
      throw Exception("Data format error");
    } catch (e) {
      status = WalletStatus.failure;
      _errorMessage = errorMsg;
      notifyListeners();
      return false;
    }
  }
}
