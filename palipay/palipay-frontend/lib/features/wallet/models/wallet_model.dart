/// 지갑 기본 정보 조회 응답 모델 (계좌번호, 이름, 잔액)
class WalletInfoModel {
  final int? walletId;
  final String? accountNumber;
  final String? accountUsername;
  final String? bankCode; // 💡 추가: 서버에서 내려주는 은행 식별 코드 (예: '081', 'wb_kr')
  final double? amount;
  final String? message;
  final String? bankCode;

  // 💡 모든 필드가 final이므로 const 생성자를 쓰는 것이 성능상 좋습니다.
  const WalletInfoModel({
    this.walletId,
    this.accountNumber,
    this.accountUsername,
    this.bankCode,
    this.amount,
    this.message,
    this.bankCode,
  });

  // 빈 모델 초기화용
  factory WalletInfoModel.empty() => const WalletInfoModel();

  // 🚀 특정 필드만 교체하기 위한 copyWith 메서드
  WalletInfoModel copyWith({
    int? walletId,
    String? accountNumber,
    String? accountUsername,
    String? bankCode,
    double? amount,
    String? message,
  }) {
    return WalletInfoModel(
      walletId: walletId ?? this.walletId,
      accountNumber: accountNumber ?? this.accountNumber,
      accountUsername: accountUsername ?? this.accountUsername,
      bankCode: bankCode ?? this.bankCode,
      amount: amount ?? this.amount,
      message: message ?? this.message,
    );
  }
}

/// 지갑 잔액 체크 응답 모델 (충전/환불 전 잔액 확인용)
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
