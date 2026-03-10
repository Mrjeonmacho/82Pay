class BankAccount {
  final String bankId;
  final String bankName; // 예: Bank of China, JPMorgan Chase 등
  final String accountNumber; // 계좌번호
  final int amount; // 실제 은행 보유금액
  final String countryCode; // KR, US, JP, CH 구분

  // 비밀번호는 모델에 저장하지 말고
  // 필요할 때만 별도의 inputcontrol로 받아서 검증

  BankAccount({
    required this.bankId,
    required this.bankName,
    required this.accountNumber,
    required this.amount,
    required this.countryCode,
  });
}
