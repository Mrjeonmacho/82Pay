// lib/features/history/models/transaction_model.dart

/// 1. 거래 내역 목록 아이템 모델 (FINANCE_HISTORY_001 반영)
class Transaction {
  final int transactionId;

  // 🚀 [해결 1] 기존 UI에서 .id를 쓰고 있으므로 게터를 추가해 연결해줍니다.
  int get id => transactionId;

  final String category;
  final double amount;
  final double? exchangeAfterAmount;
  final double? exchangeRate;
  final String? otherAccountNumber;
  final String? otherAccountName;
  final String? otherBankCode;
  final int? workplaceId;

  // 🚀 [해결 2] 타입을 String에서 DateTime으로 변경하여 UI의 DateFormat 에러를 잡습니다.
  final DateTime createdAt;

  final String? description;

  Transaction({
    required this.transactionId,
    required this.category,
    required this.amount,
    this.exchangeAfterAmount,
    this.exchangeRate,
    this.otherAccountNumber,
    this.otherAccountName,
    this.otherBankCode,
    this.workplaceId,
    required this.createdAt,
    this.description,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      transactionId: json['transactionId'] ?? 0,
      category: json['category'] ?? 'OUTPUT',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      exchangeAfterAmount: (json['exchangeAfterAmount'] as num?)?.toDouble(),
      exchangeRate: (json['exchangeRate'] as num?)?.toDouble(),
      otherAccountNumber: json['otherAccountNumber'],
      otherAccountName: json['otherAccountName'],
      otherBankCode: json['otherBankCode'],
      workplaceId: json['workplaceId'] as int?,

      // 🚀 [핵심] JSON의 String 날짜를 DateTime 객체로 변환하여 저장
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),

      description: json['description'],
    );
  }
}

/// 2. 특정 거래 상세 환산 정보 모델 (FINANCE_HISTORY_002 반영)
class TransactionCurrencyDetail {
  final int transactionId;
  final String sourceCurrency;
  final String targetCurrency;
  final double sourceAmount;
  final double exchangeRate;
  final double exchangedAmount;
  final DateTime rateTimestamp;

  TransactionCurrencyDetail({
    required this.transactionId,
    required this.sourceCurrency,
    required this.targetCurrency,
    required this.sourceAmount,
    required this.exchangeRate,
    required this.exchangedAmount,
    required this.rateTimestamp,
  });

  factory TransactionCurrencyDetail.fromJson(Map<String, dynamic> json) {
    return TransactionCurrencyDetail(
      transactionId: json['transactionId'] ?? 0,
      sourceCurrency: json['sourceCurrency'] ?? 'KRW',
      targetCurrency: json['targetCurrency'] ?? 'USD',
      sourceAmount: (json['sourceAmount'] as num?)?.toDouble() ?? 0.0,
      exchangeRate: (json['exchangeRate'] as num?)?.toDouble() ?? 0.0,
      exchangedAmount: (json['exchangedAmount'] as num?)?.toDouble() ?? 0.0,
      rateTimestamp: json['rateTimestamp'] != null
          ? DateTime.parse(json['rateTimestamp'])
          : DateTime.now(),
    );
  }
}
