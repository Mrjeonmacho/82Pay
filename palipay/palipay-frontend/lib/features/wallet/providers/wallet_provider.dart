// lib/features/wallet/providers/wallet_provider.dart

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/wallet_model.dart';
import '../services/wallet_service.dart';
import '../../../core/constants/bank_constants.dart';

enum WalletStatus { idle, loading, success, failure }

class WalletProvider extends ChangeNotifier {
  final WalletService _service = WalletService();

  // --- [1] 상태 변수 ---
  WalletStatus status = WalletStatus.idle;
  WalletBalanceModel wallet = WalletBalanceModel.empty();
  WalletInfoModel walletInfo = WalletInfoModel.empty();

  // walletId는 AccountProvider가 단일 출처 — initWalletData()로 주입받아 캐싱
  int? _walletId;

  double _krwAmount = 0;
  double _foreignAmount = 0;
  double _exchangeRate = 0;
  String _targetCurrency = 'USD';
  String? _quoteId;
  String? _rateTimestamp;
  String? _errorMessage;
  bool _isTopupView = false;

  String? _bankName;
  String? _bankLogo;

  // --- [2] Getters ---
  int? get walletId => _walletId;
  int? get currentBalance =>
      wallet.currentBalance ?? walletInfo.amount?.toInt();
  int? get balance => currentBalance;
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

  String get maskedAccountNumber {
    final acc = walletInfo.accountNumber ?? '';
    if (acc.length > 4) return '•••• ${acc.substring(acc.length - 4)}';
    return acc;
  }

  // --- [3] 초기화 — walletId를 AccountProvider에서 받아 진입 ---
  /// View의 initState에서 accountProvider.walletId를 넘겨 호출
  /// 이 메서드가 walletId 캐싱의 단일 진입점
  Future<void> initWalletData(int walletId) async {
    _walletId = walletId;
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
      walletInfo = await _service.fetchWalletInfo();

      if (walletInfo.walletId != null) {
        // walletId는 외부 주입값 우선, 없으면 서버 응답값으로 보완
        _walletId ??= walletInfo.walletId;

        final bankData = BankConstants.findBankByCode(walletInfo.bankCode);
        if (bankData != null) {
          _bankName = bankData['name'];
          _bankLogo = bankData['logo'];
        } else {
          _bankName = walletInfo.bankCode != null
              ? 'Bank (${walletInfo.bankCode})'
              : 'Unknown Bank';
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
    if (_walletId == null) {
      debugPrint('⚠️ loadWalletBalance 스킵: walletId가 없습니다.');
      return;
    }
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

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void initForTopup({String? currency}) =>
      _initForAction(isTopup: true, currency: currency ?? 'USD');
  void initForRefund({String? currency}) =>
      _initForAction(isTopup: false, currency: currency ?? 'USD');

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

  void updateBalanceManually(int newBalance) {
    wallet = wallet.copyWith(currentBalance: newBalance);
    walletInfo = walletInfo.copyWith(amount: newBalance.toDouble());
    debugPrint('💰 잔액 업데이트 완료: $newBalance');
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

  // --- [4] 트랜잭션 ---

  Future<bool> chargeWallet({required String pinNumber}) async {
    if (_walletId == null) {
      debugPrint('🚨 chargeWallet 실패: walletId 없음');
      return false;
    }
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
    if (_walletId == null) {
      debugPrint('🚨 refundWallet 실패: walletId 없음');
      return false;
    }
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
      throw Exception('Data format error');
    } catch (e) {
      status = WalletStatus.failure;
      _errorMessage = errorMsg;
      notifyListeners();
      return false;
    }
  }
}
