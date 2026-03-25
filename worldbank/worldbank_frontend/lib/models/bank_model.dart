import 'package:flutter/material.dart';

// 1. 국가/은행 분류를 위한 Enum
enum BankCountry { kr, us, jp, cn }

enum BankNationality { kr, us, jp, cn }

extension BankNationalityExt on BankNationality {
  String get label {
    return switch (this) {
      BankNationality.kr => 'KR',
      BankNationality.us => 'US',
      BankNationality.jp => 'JP',
      BankNationality.cn => 'CN',
    };
  }

  BankCountry get toBankCountry {
    return switch (this) {
      BankNationality.kr => BankCountry.kr,
      BankNationality.us => BankCountry.us,
      BankNationality.jp => BankCountry.jp,
      BankNationality.cn => BankCountry.cn,
    };
  }

  String get currencyCode {
    return switch (this) {
      BankNationality.kr => 'KRW',
      BankNationality.us => 'USD',
      BankNationality.jp => 'JPY',
      BankNationality.cn => 'CNY',
    };
  }
}

extension BankCountryExt on BankCountry {
  BankNationality get toBankNationality {
    return switch (this) {
      BankCountry.kr => BankNationality.kr,
      BankCountry.us => BankNationality.us,
      BankCountry.jp => BankNationality.jp,
      BankCountry.cn => BankNationality.cn,
    };
  }
}

// 2. 이체(Transfer) 관련 모델 (IDFINANCE_001)
class TransactionModel {
  final String senderAccountNumber;
  final String senderAccountName;
  final String senderBankCode;
  final double senderAmount;
  final String senderCurrency;

  final String targetAccountNumber;
  final String targetAccountName;
  final String targetBankCode;
  final double targetAmount;
  final String targetCurrency;

  TransactionModel({
    required this.senderAccountNumber,
    required this.senderAccountName,
    required this.senderBankCode,
    required this.senderAmount,
    required this.senderCurrency,
    required this.targetAccountNumber,
    required this.targetAccountName,
    required this.targetBankCode,
    required this.targetAmount,
    required this.targetCurrency,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      senderAccountNumber: json['senderAccountNumber'] ?? '',
      senderAccountName: json['senderAccountName'] ?? '',
      senderBankCode: json['senderBankCode'] ?? '',
      senderAmount: (json['senderAmount'] as num).toDouble(),
      senderCurrency: json['senderCurrency'] ?? 'KRW',
      targetAccountNumber: json['targetAccountNumber'] ?? '',
      targetAccountName: json['targetAccountName'] ?? '',
      targetBankCode: json['targetBankCode'] ?? '',
      targetAmount: (json['targetAmount'] as num).toDouble(),
      targetCurrency: json['targetCurrency'] ?? 'KRW',
    );
  }

  Map<String, dynamic> toJson() => {
    'senderAccountNumber': senderAccountNumber,
    'senderAccountName': senderAccountName,
    'senderBankCode': senderBankCode,
    'senderAmount': senderAmount,
    'senderCurrency': senderCurrency,
    'targetAccountNumber': targetAccountNumber,
    'targetAccountName': targetAccountName,
    'targetBankCode': targetBankCode,
    'targetAmount': targetAmount,
    'targetCurrency': targetCurrency,
  };
}

// 3. 잔액 조회 모델 (IDFINANCE_CHECK_001/002)
class BalanceModel {
  final double amount;
  final String currency;

  BalanceModel({required this.amount, required this.currency});

  factory BalanceModel.fromJson(Map<String, dynamic> json) {
    final amountValue = json['amount'] ?? json['targetAmount'] ?? 0;
    return BalanceModel(
      amount: (amountValue as num).toDouble(),
      currency: json['currency'] ?? 'KRW',
    );
  }
}

// 4. 한국 전용 사업자 모델 (IDFINANCE_CORPORATION_001)
class BusinessModel {
  final String companyName; // 싸피청과
  final String businessPerson; // 홍길동

  BusinessModel({required this.companyName, required this.businessPerson});

  String get headerTitle => '[$companyName] $businessPerson';

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      companyName: json['companyName'] ?? '',
      businessPerson: json['businessPerson'] ?? '',
    );
  }
}

// 5. 공유 사용자/계좌 모델
class UserModel {
  final String userId;
  final String userName;
  final String currency; // 로그인 user의 통화 정보

  UserModel({
    required this.userId,
    required this.userName,
    this.currency = 'KRW',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? 'guest',
      userName: json['userName'] ?? 'User',
      currency: json['currency'] ?? 'KRW',
    );
  }
}

class BankAccount {
  final String accountName;
  final String accountNumber;
  final double balance;
  final String bankName;

  BankAccount({
    required this.accountName,
    required this.accountNumber,
    required this.balance,
    required this.bankName,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      accountName: json['accountName'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      bankName: json['bankName'] ?? '',
    );
  }
}

enum TransactionType { deposit, withdrawal, transfer, payment, refund, fee }

extension TransactionTypeExt on TransactionType {
  String labelFor(BankNationality nationality) {
    return switch (this) {
      TransactionType.deposit =>
        nationality == BankNationality.kr
            ? '입금'
            : nationality == BankNationality.us
            ? 'Deposit'
            : nationality == BankNationality.jp
            ? '入金'
            : '存款',
      TransactionType.withdrawal =>
        nationality == BankNationality.kr
            ? '출금'
            : nationality == BankNationality.us
            ? 'Withdrawal'
            : nationality == BankNationality.jp
            ? '出金'
            : '取款',
      TransactionType.transfer =>
        nationality == BankNationality.kr
            ? '이체'
            : nationality == BankNationality.us
            ? 'Transfer'
            : nationality == BankNationality.jp
            ? '振込'
            : '转账',
      TransactionType.payment =>
        nationality == BankNationality.kr
            ? '결제'
            : nationality == BankNationality.us
            ? 'Payment'
            : nationality == BankNationality.jp
            ? '支払い'
            : '支付',
      TransactionType.refund =>
        nationality == BankNationality.kr
            ? '환불'
            : nationality == BankNationality.us
            ? 'Refund'
            : nationality == BankNationality.jp
            ? '返金'
            : '退款',
      TransactionType.fee =>
        nationality == BankNationality.kr
            ? '수수료'
            : nationality == BankNationality.us
            ? 'Fee'
            : nationality == BankNationality.jp
            ? '手数料'
            : '手续费',
    };
  }

  IconData get icon {
    return switch (this) {
      TransactionType.deposit => Icons.arrow_downward,
      TransactionType.withdrawal => Icons.arrow_upward,
      TransactionType.transfer => Icons.swap_horiz,
      TransactionType.payment => Icons.receipt_long,
      TransactionType.refund => Icons.undo,
      TransactionType.fee => Icons.money_off,
    };
  }
}

class TransactionHistory {
  final String historyId;
  final TransactionType type;
  final bool isCredit;
  final String counterParty;
  final String? memo;
  final DateTime transactedAt;
  final double amount;
  final double balanceAfter;

  TransactionHistory({
    required this.historyId,
    required this.type,
    required this.isCredit,
    required this.counterParty,
    this.memo,
    required this.transactedAt,
    required this.amount,
    required this.balanceAfter,
  });

  factory TransactionHistory.fromTransfer({
    required String historyId,
    required TransactionModel transfer,
    required TransactionType type,
    required bool isCredit,
    required String counterParty,
    String? memo,
    required DateTime transactedAt,
    required double balanceAfter,
  }) {
    return TransactionHistory(
      historyId: historyId,
      type: type,
      isCredit: isCredit,
      counterParty: counterParty,
      memo: memo,
      transactedAt: transactedAt,
      amount: transfer.targetAmount,
      balanceAfter: balanceAfter,
    );
  }
}

// 6. 공통 API 응답 래퍼 (성공 메시지 처리용)
class ApiResponse<T> {
  final String message;
  final T? data;

  ApiResponse({required this.message, this.data});
}
