import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/wallet_model.dart';
import '../services/wallet_service.dart';

enum WalletStatus { idle, loading, success, failure }

class WalletProvider extends ChangeNotifier {
  final WalletService _service = WalletService();

  WalletStatus status = WalletStatus.idle;
  WalletBalanceModel wallet = WalletBalanceModel.empty();

  // 🚀 NEW: 지갑 기본 정보 (계좌번호, 이름, 잔액)
  WalletInfoModel walletInfo = WalletInfoModel.empty();

  // 💾 walletId 캐싱 - pin, transfer 등 모든 거래에서 사용
  int? _walletId;

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

  // 🚀 NEW: 지갑 정보 Getters
  String? get accountNumber => walletInfo.accountNumber;
  String? get accountUsername => walletInfo.accountUsername;
  double? get walletAmount => walletInfo.amount;

  // 💾 walletId 캐싱된 ID 조회 - 모든 거래에서 사용
  int? get walletId => _walletId;

  // --- [2] 초기화 로직 ---
  Future<void> initWalletData() async {
    status = WalletStatus.loading;
    notifyListeners();

    try {
      // 🚀 주소 변경에 맞춰 인자 없이 호출합니다.
      await loadWalletInfo();

      // 만약 balance 조회에는 여전히 ID가 필요하다면,
      // 위에서 받아온 walletInfo의 ID를 사용하게 연결합니다.
      if (walletId != null) {
        await loadWalletBalance(walletId: walletId!);
      }

      status = WalletStatus.success;
    } catch (e) {
      status = WalletStatus.failure;
    }
    notifyListeners();
  }

  void initForTopup({String? currency}) =>
      initForAction(isTopup: true, currency: currency ?? "USD");
  void initForRefund({String? currency}) =>
      initForAction(isTopup: false, currency: currency ?? "USD");

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
      final response = await _service.getExchangeRateQuote(
        currency: _targetCurrency,
      );
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

  /// 🚀 NEW: 지갑 기본 정보 조회 (계좌번호, 이름, 잔액)
  Future<void> loadWalletInfo() async {
    try {
      // 1. 서비스 호출 (인자 필요 없음)
      walletInfo = await _service.fetchWalletInfo();

      // 2. 가져온 정보에 walletId가 있다면 캐싱
      if (walletInfo.walletId != null) {
        _walletId = walletInfo.walletId; // 이제 isn't defined 에러 해결! ✅
      }

      notifyListeners();
    } catch (e) {
      debugPrint('🚨 지갑 정보 로드 실패: $e');
      rethrow;
    }
  }

  Future<void> loadWalletBalance({
    required int walletId, // 잔액 조회 API는 여전히 ID를 쓸 수 있으니 유지
    num? amount,
  }) async {
    try {
      wallet = await _service.fetchWalletBalance(
        walletId: walletId,
        amount: amount ?? 0,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('🚨 잔액 조회 실패: $e');
    }
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

  // --- [5] 트랜잭션 실행 (충전/환급) ---

  Future<bool> chargeWallet({
    required int walletId,
    required String pinNumber,
  }) async {
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

  Future<bool> refundWallet({
    required int walletId,
    required String pinNumber,
  }) async {
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
        wallet = wallet.copyWith(
          currentBalance: (data['currentBalance'] as num).toInt(),
        );
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
