import 'package:flutter/material.dart';
import '../models/wallet_balance_model.dart';
import '../services/wallet_service.dart';

enum WalletStatus {
  idle,
  loading,
  success,
  failure,
}

class WalletProvider extends ChangeNotifier {
  final WalletService _service = WalletService();

  WalletStatus status = WalletStatus.idle;
  WalletBalanceModel wallet = WalletBalanceModel.empty();

  int? get balance => wallet.currentBalance;
  bool get isLoading => status == WalletStatus.loading;

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