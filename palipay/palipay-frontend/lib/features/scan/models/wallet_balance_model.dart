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
}