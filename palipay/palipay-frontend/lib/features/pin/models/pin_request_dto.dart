// 핀 데이터에 대한 DTO 클래스 정의
// 보안상 직접 model로 PIN 정보를 저장할 수 없으니 DTO로 요청 시에만 사용
// 핀 생성 요청용 (USER_ACCOUNT_003)

class PinCreateRequest {
  final int walletId;
  final String pinNumber;

  PinCreateRequest({required this.walletId, required this.pinNumber});

  // JSON 변환 메서드 (Dio 요청 시 사용)
  Map<String, dynamic> toJson() => {
    'walletId': walletId,
    'pinNumber': pinNumber,
  };
}

// 핀 변경 요청용 (USER_ACCOUNT_004)
class PinUpdateRequest {
  final int walletId;
  final String oldPinNumber;
  final String newPinNumber;

  PinUpdateRequest({
    required this.walletId,
    required this.oldPinNumber,
    required this.newPinNumber,
  });

  Map<String, dynamic> toJson() => {
    'walletId': walletId,
    'oldPinNumber': oldPinNumber,
    'newPinNumber': newPinNumber,
  };
}

// 3. 핀 검증 요청용 (송금/결제 직전 확인용)
// class PinVerifyRequest {
//   final int walletId;
//   final String pinNumber;

//   PinVerifyRequest({required this.walletId, required this.pinNumber});

//   Map<String, dynamic> toJson() => {
//     'walletId': walletId,
//     'pinNumber': pinNumber,
//   };
// }
