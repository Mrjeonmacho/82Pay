// 프론트에서 관리하는 UI용 모델 (DTO를 그대로 사용해도 되지만, 가독성을 위해 분리)
// lib/features/transfer/models/transfer_request.dart

class TransferRequest {
  final int walletId; // 명세: Bigint -> int (내 지갑 ID)
  final String otherBankCode; // 명세: Enum -> String (상대 은행 코드)
  final String otherAccountNumber; // 명세: String (상대 계좌번호)
  final String otherAccountName; // 명세: String (상대 예금주)
  final double amount; // 명세: decimal -> double (송금 금액)
  final String accountCurrency; // 🚀 [추가] 통화 코드 필드 (예: "KRW")
  final String pinNumber; // 명세: String (필수항목으로 변경)
  final String? description; // 명세: String (선택)
  final int? workplaceId; // 명세: Bigint -> int (선택)

  TransferRequest({
    required this.walletId,
    required this.otherBankCode,
    required this.otherAccountNumber,
    required this.otherAccountName,
    required this.amount,
    required this.accountCurrency, // 🚀 [추가] 생성자에 통화 코드 필드 추가
    required this.pinNumber, // 필수(required)로 변경
    this.description,
    this.workplaceId,
  });

  // API 전송을 위한 변환 로직
  Map<String, dynamic> toJson() => {
    'walletId': walletId, // int로 전송
    'otherBankCode': otherBankCode,
    'otherAccountNumber': otherAccountNumber,
    'otherAccountName': otherAccountName,
    'amount': amount,
    'accountCurrency': accountCurrency, // 🚀 [추가] 통화 코드 포함
    'pinNumber': pinNumber, // 필수값이므로 if문 제거
    // 값이 있을 때만 포함 (명세서 X 표시 대응)
    if (description != null && description!.isNotEmpty)
      'description': description,
    if (workplaceId != null) 'workplaceId': workplaceId,
  };
}
