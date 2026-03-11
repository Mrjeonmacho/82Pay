// lib/features/history/models/transaction_model.dart

// [FINANCE_HISTORY_001] 기반 메인 목록 모델
class Transaction {
  final int id;
  final String category; // INPUT(입금), OUTPUT(출금)
  final double amount;
  final String? otherAccountName; // 상대 예금주 (가게명 등)
  final DateTime createdAt;
  final String? description; // 메모

  Transaction({
    required this.id,
    required this.category,
    required this.amount,
    this.otherAccountName,
    required this.createdAt,
    this.description,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['transactionId'],
    category: json['category'],
    amount: (json['amount'] as num).toDouble(),
    otherAccountName: json['otherAccountName'],
    createdAt: DateTime.parse(json['createdAt']),
    description: json['description'],
  );
}

// 환율정보 API 기반 모델
// [FINANCE_HISTORY_002] 기반 상세 환산 정보 모델
class TransactionCurrencyDetail {
  final double exchangeRate;
  final double exchangedAmount;
  final String targetCurrency;
  final DateTime rateTimestamp;

  TransactionCurrencyDetail({
    required this.exchangeRate,
    required this.exchangedAmount,
    required this.targetCurrency,
    required this.rateTimestamp,
  });
}
