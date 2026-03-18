class TransferRequest {
  final String toBank;
  final String toAccount;
  final String toName;
  final int amount;
  final String? memo;

  TransferRequest({
    required this.toBank,
    required this.toAccount,
    required this.toName,
    required this.amount,
    this.memo,
  });
}
