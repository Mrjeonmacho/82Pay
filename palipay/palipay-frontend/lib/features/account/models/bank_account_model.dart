class BankAccount {
  final String walletId; // 연동할 지갑 ID [추가]
  final String bankCode; // 은행 코드
  final String bankName; // 예: Bank of China, JPMorgan Chase 등 -> 화면 유지용
  final String accountNumber; // 계좌번호
  final String accountUsername; // 예금주명
  final String accountPassword; // 계좌 비밀번호
  final String moneyCode; // KR, US, JP, CH 구분
  final int? amount; // 실제 은행 보유금액

  // 비밀번호는 모델에 저장하지 말고
  // 필요할 때만 별도의 inputcontrol로 받아서 검증

  BankAccount({
    required this.walletId,
    required this.bankCode,
    required this.bankName,
    required this.accountNumber,
    required this.accountUsername,
    required this.accountPassword,
    required this.moneyCode,
    this.amount,
  });

  BankAccount copyWith({
    String? walletId,
    String? bankCode,
    String? bankName,
    String? accountNumber,
    String? accountUsername,
    String? accountPassword,
    String? moneyCode,
    int? amount,
  }) {
    return BankAccount(
      walletId: walletId ?? this.walletId,
      bankCode: bankCode ?? this.bankCode,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      accountUsername: accountUsername ?? this.accountUsername,
      accountPassword: accountPassword ?? this.accountPassword,
      moneyCode: moneyCode ?? this.moneyCode,
      amount: amount ?? this.amount,
    );
  }
}
