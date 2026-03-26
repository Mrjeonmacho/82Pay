// 실제 백엔드의 규격을 따르는 DTO

// [잔액 확인 FINANCE/CHECK 001]
// Request: 서버로 보낼 때
class BalanceCheckRequest {
  final int walletId; // String -> int 로 수정 (명세서 0 기준)
  final double amount;

  BalanceCheckRequest({required this.walletId, required this.amount});

  Map<String, dynamic> toJson() => {'walletId': walletId, 'amount': amount};
}

// Response: 서버에서 받을 때
class BalanceCheckResponse {
  final bool isSufficient;
  final double currentBalance;
  final double requiredAmount;
  final double? shortageAmount;

  BalanceCheckResponse({
    required this.isSufficient,
    required this.currentBalance,
    required this.requiredAmount,
    this.shortageAmount,
  });

  factory BalanceCheckResponse.fromJson(Map<String, dynamic> json) =>
      BalanceCheckResponse(
        isSufficient: json['isSufficient'],
        currentBalance: (json['currentBalance'] as num).toDouble(),
        requiredAmount: (json['requiredAmount'] as num).toDouble(),
        shortageAmount: json['shortageAmount'] != null
            ? (json['shortageAmount'] as num).toDouble()
            : null,
      );
}

// [송금 전 최종 검증 FINANCE/TRANSFER 001]
class TransferValidateResponse {
  final String message;
  final bool isValid;
  final List<ValidationError>? validationErrors; // 리스트 객체 대응

  TransferValidateResponse({
    required this.message,
    required this.isValid,
    this.validationErrors,
  });

  factory TransferValidateResponse.fromJson(Map<String, dynamic> json) {
    return TransferValidateResponse(
      message: json['message'] as String? ?? '',
      isValid: json['isValid'] as bool? ?? false,
      // 리스트 파싱은 항상 조심스럽게!
      validationErrors: (json['validationErrors'] as List?)
          ?.map((e) => ValidationError.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ValidationError {
  final String field;
  final String reason;

  ValidationError({required this.field, required this.reason});

  factory ValidationError.fromJson(Map<String, dynamic> json) {
    return ValidationError(
      field: json['field'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
    );
  }
}

// [송금 실행 FINANCE/TRANSFER 002]
class TransferExecuteResponse {
  final String message;
  final String transferId;
  final int transactionId;
  final String status;
  final double currentBalance;
  final String createdAt;

  TransferExecuteResponse({
    required this.message,
    required this.transferId,
    required this.transactionId,
    required this.status,
    required this.currentBalance,
    required this.createdAt,
  });

  factory TransferExecuteResponse.fromJson(Map<String, dynamic> json) {
    // 💡 핵심: 'data' 계층 안에서 값을 꺼내야 함
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return TransferExecuteResponse(
      message: json['message']?.toString() ?? '',
      transferId: data['transferId']?.toString() ?? '',
      transactionId: data['transactionId'] is int
          ? data['transactionId']
          : int.tryParse(data['transactionId']?.toString() ?? '0') ?? 0,
      status: data['status']?.toString() ?? '',
      currentBalance: (data['currentBalance'] as num?)?.toDouble() ?? 0.0,
      createdAt: data['createdAt']?.toString() ?? '',
    );
  }
}

// --- [이체 실패 처리 FINANCE/TRANSFER 003] ---

/// Request: 서버로 실패 사유를 보낼 때 (보통 '모델'보다는 'DTO' 명칭이 정확합니다)
class TransferFailRequest {
  final String reasonCode;
  final String? reasonMessage;
  final bool rollback;

  TransferFailRequest({
    required this.reasonCode,
    this.reasonMessage,
    required this.rollback,
  });

  Map<String, dynamic> toJson() => {
    'reasonCode': reasonCode,
    'reasonMessage': reasonMessage,
    'rollback': rollback,
  };
}

/// Response: 서버에서 실패 처리 결과를 받을 때
class TransferFailResponse {
  final String message;
  final String transferId;
  final String status;
  final bool rolledBack;

  TransferFailResponse({
    required this.message,
    required this.transferId,
    required this.status,
    required this.rolledBack,
  });

  factory TransferFailResponse.fromJson(Map<String, dynamic> json) {
    // 명세서 예시처럼 'data' 계층이 있는 경우를 대비한 안전한 파싱
    final data = json['data'] as Map<String, dynamic>? ?? json;

    return TransferFailResponse(
      message: json['message']?.toString() ?? '',
      transferId: data['transferId']?.toString() ?? '',
      status: data['status']?.toString() ?? 'FAILED',
      rolledBack: data['rolledBack'] as bool? ?? false,
    );
  }
}
