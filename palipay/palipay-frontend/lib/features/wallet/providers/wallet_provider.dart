import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/wallet_model.dart';
import '../services/wallet_service.dart';

enum WalletStatus { idle, loading, success, failure } // 상태 관리

class WalletProvider extends ChangeNotifier {
  final WalletService _service = WalletService();

  WalletStatus status = WalletStatus.idle;
  WalletBalanceModel wallet = WalletBalanceModel.empty();

  // --- 추가된 상태 값들 (기획서 반영) ---
  // 초기값은 시안에 있던 데이터를 기본으로 세팅해두었습니다.
  String _selectedBankName = "WELS FARGO";
  String _selectedBankAccount = "US Account •••• 1234";
  double _krwAmount = 0; // 입력된 원화 금액
  double _foreignAmount = 0; // 환산된 외화 금액
  double _exchangeRate = 1472.70; // 실시간 환율 (임시, API 호출로 덮어씌워짐)
  String _targetCurrency = "USD"; // 대상 통화
  String? _quoteId; // 백엔드로부터 발급받은 환율 견적 ID
  String? _rateTimestamp; // 환율 기준 시각

  int? get balance => wallet.currentBalance;
  String? get quoteId => _quoteId;
  String? get rateTimestamp => _rateTimestamp;
  String get targetCurrency => _targetCurrency;
  String? _errorMessage; // "금액이 부족합니다" 등의 메시지
  bool _isTopupView = false; // 현재 화면이 Topup인지 Refund인지 구분

  // Getters
  String get selectedBankName => _selectedBankName;
  String get selectedBankAccount => _selectedBankAccount;
  int? get currentBalance => wallet.currentBalance;
  double get krwAmount => _krwAmount;
  double get foreignAmount => _foreignAmount;
  double get exchangeRate => _exchangeRate;
  String? get errorMessage => _errorMessage;
  bool get isLoading => status == WalletStatus.loading;

  // --- 0. 계좌 선택 정보 업데이트 ---
  // 사용자가 리스트에서 다른 은행을 선택하면 이 함수를 호출합니다.
  void updateSelectedAccount(String bankName, String accountNumber) {
    _selectedBankName = bankName;
    _selectedBankAccount = accountNumber;
    notifyListeners(); // UI에 즉시 반영 (TopupView의 카드 글자가 바뀜)
  }

  Future<void> initWalletData() async {
  // 일단 테스트를 위해 고정값으로 호출하게 만듭니다.
  await loadWalletBalance(
    accessToken: '', // 인터셉터가 넣어줄 거라 비워둬도 됨
    walletId: 1, 
    amount: 0,
  );
}

  // --- 화면 진입 시 상태 초기화 ---

  
  void initForTopup() {
    _isTopupView = true;
    _resetInputState();
  }

  void initForRefund() {
    _isTopupView = false;
    _resetInputState();
  }

  void _resetInputState() {
    _krwAmount = 0;
    _foreignAmount = 0;
    _errorMessage = null;
    notifyListeners();
  }

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
    // 환급일 때만 가상 지갑 잔액 부족을 체크함 (충전 시에는 은행 잔고를 모르므로 무시)
    if (!_isTopupView && wallet.currentBalance != null && _krwAmount > wallet.currentBalance!) {
      _errorMessage = 'wallet.error.insufficient_balance'.tr();
    } else if (_krwAmount > 2000000) {
      _errorMessage = 'wallet.error.max_limit'.tr();
    } else {
      _errorMessage = null;
    }
  }

  // 5. 서버로부터 환율 정보 갱신 (GET /finance/quote)
  Future<void> loadExchangeRateQuote() async {
    try {
      final response = await _service.getExchangeRateQuote(currency: _targetCurrency);
      final data = response['data'];
      if (data != null && data['exchangeRate'] != null) {
        _exchangeRate = (data['exchangeRate'] as num).toDouble();
        _quoteId = data['quoteId'];
        _rateTimestamp = data['rateTimestamp'];
        
        // 환율 변동으로 인해 현재 입력되어 있는 원화, 외화 금액 다시 재계산
        if (_krwAmount > 0) {
          updateKrwAmount(_krwAmount);
        }
      }
    } catch (e) {
      debugPrint('환율 견적 생성 실패: $e');
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
      final response = await _service.fetchWalletBalance(
        accessToken: accessToken ?? '',
        walletId: walletId,
        amount: amount,
      );

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

  // --- 서버 연동 API 메서드 추가 ---
  int? _maxRefundableAmount;
  int? get maxRefundableAmount => _maxRefundableAmount;

  // 1. 충전 로직 (POST /finance/charges)
  Future<bool> chargeWallet({
    required int walletId,
    required String pinNumber,
  }) async {
    status = WalletStatus.loading;
    notifyListeners();

    try {
      final response = await _service.chargeWallet(
        walletId: walletId,
        pinNumber: pinNumber,
        accountCurrency: _targetCurrency,
        convertedAmount: _krwAmount,
        amount: _foreignAmount,
      );

      final data = response['data'];
      if (data != null && data['currentBalance'] != null) {
        // 잔액 모델 업데이트
        wallet = wallet.copyWith(currentBalance: (data['currentBalance'] as num).toInt());
      }
      status = WalletStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      status = WalletStatus.failure;
      _errorMessage = '충전에 실패했습니다.';
      notifyListeners();
      return false;
    }
  }

  // 2. 환불 로직 (POST /finance/refunds)
  Future<bool> refundWallet({
    required int walletId,
    required String pinNumber,
  }) async {
    status = WalletStatus.loading;
    notifyListeners();

    try {
      final response = await _service.refundWallet(
        walletId: walletId,
        pinNumber: pinNumber,
        accountCurrency: _targetCurrency,
        convertedAmount: _krwAmount,
        amount: _foreignAmount,
      );

      final data = response['data'];
      if (data != null && data['currentBalance'] != null) {
        wallet = wallet.copyWith(currentBalance: (data['currentBalance'] as num).toInt());
      }
      status = WalletStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      status = WalletStatus.failure;
      _errorMessage = '환급에 실패했습니다.';
      notifyListeners();
      return false;
    }
  }

  // 3. 최대 환불 가능 금액 조회 (GET /finance/refunds/max)
  Future<void> loadMaxRefundable(int walletId) async {
    try {
      final response = await _service.getMaxRefundable(walletId: walletId);
      final data = response['data'];
      if (data != null && data['maxRefundableAmount'] != null) {
        _maxRefundableAmount = (data['maxRefundableAmount'] as num).toInt();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('최대 환불 가능 금액 조회 실패: $e');
    }
  }
}
