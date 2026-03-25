class WalletBalanceModel {
  final int? currentBalance;
  final bool? isSufficient;
  final int? requiredAmount;
  final int? shortageAmount;
  final String? message;

  const WalletBalanceModel({
    this.currentBalance,
    this.isSufficient,
    this.requiredAmount,
    this.shortageAmount,
    this.message,
  });

  factory WalletBalanceModel.empty() {
    return const WalletBalanceModel(
      currentBalance: null,
      isSufficient: null,
      requiredAmount: null,
      shortageAmount: null,
      message: null,
    );
  }

  WalletBalanceModel copyWith({
    int? currentBalance,
    bool? isSufficient,
    int? requiredAmount,
    int? shortageAmount,
    String? message,
  }) {
    return WalletBalanceModel(
      currentBalance: currentBalance ?? this.currentBalance,
      isSufficient: isSufficient ?? this.isSufficient,
      requiredAmount: requiredAmount ?? this.requiredAmount,
      shortageAmount: shortageAmount ?? this.shortageAmount,
      message: message ?? this.message,
    );
  }
}
