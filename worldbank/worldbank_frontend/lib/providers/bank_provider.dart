import 'package:flutter/material.dart';
import '../models/bank_model.dart';
import '../services/bank_service.dart';

class BankProvider extends ChangeNotifier {
  final BankService _service;

  BankProvider({BankService? service})
    : _service = service ?? BankService(accessToken: '') {
    _initData();
  }

  // 상태
  BankNationality _nationality = BankNationality.kr;
  UserModel _user = UserModel(
    userId: 'guest',
    userName: 'Guest',
    currency: 'KRW',
  );
  BankAccount _account = BankAccount(
    accountName: '',
    accountNumber: '',
    balance: 0,
    bankName: '',
  );
  List<TransactionHistory> _transactions = [];
  BalanceModel? _balance;
  BusinessModel? _business;
  bool _isLoading = false;
  bool _isDepositing = false;

  BankNationality get nationality => _nationality;
  UserModel get user => _user;
  String get userCurrency => _user.currency;
  BankAccount get account => _account;
  List<TransactionHistory> get transactions => List.unmodifiable(_transactions);
  BalanceModel? get balance => _balance;
  BusinessModel? get business => _business;
  bool get isLoading => _isLoading;
  bool get isDepositing => _isDepositing;

  double get currentAmount => _balance?.amount ?? _account.balance;
  String get currencySymbol => _balance?.currency ?? 'KRW';

  BankNationality _mapCurrencyToNationality(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return BankNationality.us;
      case 'JPY':
        return BankNationality.jp;
      case 'CNY':
        return BankNationality.cn;
      default:
        return BankNationality.kr;
    }
  }

  void updateUser(UserModel user) {
    _user = user;
    _nationality = _mapCurrencyToNationality(user.currency);
    _initData();
  }

  Future<void> _initData() async {
    _isLoading = true;
    notifyListeners();

    // 로그인된 사용자 통화 우선으로 국가를 결정
    _nationality = _mapCurrencyToNationality(_user.currency);

    // 1. 잔액 조회
    final balanceRes = await _service.fetchBalance(_user.userId);
    _balance = balanceRes.data;

    // 서버가 리턴한 통화가 있으면, 그에 따라 네이션도 맞춰주기
    if (_balance != null && _balance!.currency.isNotEmpty) {
      _nationality = _mapCurrencyToNationality(_balance!.currency);
    }

    // // 2. 한국(KR)인 경우에만 사업자 테이블 조회 (기획 의도 반영)
    // if (_nationality == BankNationality.kr) {
    //   final bizRes = await _service.fetchBusinessInfo(account.accountNumber);
    //   _business = bizRes.data;
    // } else {
    //   _business = null; // 타 국적은 깔끔하게 null 유지
    // }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> switchNationality(BankNationality nationality) async {
    if (_nationality == nationality) return;
    _nationality = nationality;
    await _initData();
  }

  Future<void> simulateDeposit({double amount = 500.0}) async {
    // _balance가 null인지 먼저 확실히 체크
    final currentBalance = _balance;
    if (_isDepositing || currentBalance == null) return;

    _isDepositing = true;
    notifyListeners();

    try {
      final depositResult = await _service.deposit(
        nationality: _nationality,
        amount: amount,
        currency: currentBalance.currency,
        account: _account,
        currentBalance: currentBalance.amount,
      );

      // ! 대신 if let 방식으로 안전하게 추출
      final newTx = depositResult.data;
      if (newTx != null) {
        _transactions = [newTx, ..._transactions];

        // 잔액 업데이트도 안전하게
        final nextAmount = currentBalance.amount + amount;
        _balance = BalanceModel(
          amount: nextAmount,
          currency: currentBalance.currency,
        );

        // _account 업데이트 생략 가능 혹은 안전하게 처리
      }
    } catch (e) {
      debugPrint('simulateDeposit failed: $e');
    } finally {
      _isDepositing = false;
      notifyListeners();
    }
  }
}
