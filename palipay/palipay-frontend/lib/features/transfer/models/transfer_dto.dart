// 실제 백엔드의 규격을 따르는 DTO

// [잔액 확인 FINANCE/CHECK 001]
// Request: 서버로 보낼 때
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
        isSufficient: json['isSufficient'] as bool? ?? false,
        currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0.0,
        requiredAmount: (json['requiredAmount'] as num?)?.toDouble() ?? 0.0,
        // 보다 간결한 null-safe 파싱
        shortageAmount: (json['shortageAmount'] as num?)?.toDouble(),
      );
}

// [송금 전 최종 검증 FINANCE/TRANSFER 001]
// lib/features/transfer/models/transfer_dto.dart

class TransferValidateResponse {
  final String message;
  final bool isValid; // 🚀 이 값이 false로 파싱되면 다음 단계로 못 가!
  final List<ValidationError>? validationErrors;

  TransferValidateResponse({
    required this.message,
    required this.isValid,
    this.validationErrors,
  });

  factory TransferValidateResponse.fromJson(Map<String, dynamic> json) {
    // ❌ final data = json['data']; <- 이거 있으면 지워! 서비스에서 이미 까서 줬음.
    return TransferValidateResponse(
      // 🚀 json이 비어있거나 필드가 없어도 튕기지 않게 ?? 처리
      message: json['message'] as String? ?? '검증 데이터가 없습니다.',
      isValid: json['isValid'] as bool? ?? false,
      validationErrors:
          (json['validationErrors'] as List?)
              ?.map((e) => ValidationError.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [], // null이면 빈 리스트 반환
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
  final String transferId;
  final int transactionId;
  final String status;
  final double currentBalance;
  final String createdAt;

  TransferExecuteResponse({
    required this.transferId,
    required this.transactionId,
    required this.status,
    required this.currentBalance,
    required this.createdAt,
  });

  factory TransferExecuteResponse.fromJson(Map<String, dynamic> json) {
    // 💡 팁: 서비스에서 data를 까서 줬다면 여기서 바로 필드에 접근합니다.
    return TransferExecuteResponse(
      transferId: json['transferId']?.toString() ?? '',
      // Bigint 대응: int일 수도, String일 수도 있는 상황 방어
      transactionId: json['transactionId'] is int
          ? json['transactionId']
          : int.tryParse(json['transactionId']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? 'PENDING',
      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt']?.toString() ?? '',
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
