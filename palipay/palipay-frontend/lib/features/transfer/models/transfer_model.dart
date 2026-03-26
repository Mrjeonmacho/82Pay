// 프론트에서 관리하는 UI용 모델 (DTO를 그대로 사용해도 되지만, 가독성을 위해 분리)
class TransferRequest {
  final String walletId;        // 내 지갑 ID (bigint 대응)
  final String otherBankCode;   // 상대 은행 코드 (명세: otherBankCode)
  final String otherAccountNumber; // 상대 계좌번호 (명세: otherAccountNumber)
  final String otherAccountName;   // 상대 예금주 (명세: otherAccountName)
  final double amount;          // 송금 금액 (decimal 대응)
  final String? description;    // 메모 (명세: description)
  final String? pinNumber;      // PIN 번호 (검증 및 실행 시 필요)

  final String? workplaceId;    // 거래 장소 (선택)

  TransferRequest({
    required this.walletId,
    required this.otherBankCode,
    required this.otherAccountNumber,
    required this.otherAccountName,
    required this.amount,
    this.description,
    this.pinNumber,
    this.workplaceId,
  });

  // API 전송을 위한 변환 로직
  Map<String, dynamic> toJson() => {
    'walletId': walletId, // 백엔드 확인 후 필요시 int.parse() 혹은 타입 변경
    'otherBankCode': otherBankCode,
    'otherAccountNumber': otherAccountNumber,
    'otherAccountName': otherAccountName,
    'amount': amount,
    if (description != null && description!.isNotEmpty) 'description': description,
    if (pinNumber != null) 'pinNumber': pinNumber,
    if (workplaceId != null) 'workplaceId': workplaceId,
  };
}