class ScanResultModel {
  final bool success;
  final String? bankName;
  final String? accountNumber;
  final String? errorMessage;

  const ScanResultModel({
    required this.success,
    this.bankName,
    this.accountNumber,
    this.errorMessage,
  });

  factory ScanResultModel.fromJson(Map<String, dynamic> json) {
    final parsed = json['parsed'] as Map<String, dynamic>?;

    final rawBankName = parsed?['bank_name']?.toString().trim();
    final rawAccountNumber = parsed?['account_number']?.toString().trim();

    final mappedBankName = _mapBankName(rawBankName);

    final isSuccess =
        mappedBankName != null &&
        mappedBankName.isNotEmpty &&
        rawAccountNumber != null &&
        rawAccountNumber.isNotEmpty;

    return ScanResultModel(
      success: isSuccess,
      bankName: mappedBankName,
      accountNumber: rawAccountNumber,
      errorMessage: isSuccess ? null : '계좌 정보를 인식하지 못했습니다.',
    );
  }

  factory ScanResultModel.failure([String? message]) {
    return ScanResultModel(
      success: false,
      errorMessage: message ?? 'OCR 요청에 실패했습니다.',
    );
  }

  static String? _mapBankName(String? bankName) {
    if (bankName == null || bankName.trim().isEmpty) return null;

    final normalized = bankName.replaceAll(' ', '').trim();

    switch (normalized) {
      case '국민':
      case 'KB':
      case 'KB국민':
      case '국민은행': 
      case 'KB국민은행':
      case 'KB은행':
        return 'KB국민';

      case '신한':
      case '신한은행':
        return '신한';

      case '우리':
      case '우리은행':
        return '우리';

      case '하나':
      case '하나은행':
        return '하나';
      
      case '농협':
      case 'NH':
      case '농협은행':
      case 'NH농협은행':
      case 'NH농협':
      case 'NH은행':
        return 'NH농협';

      case '기업':
      case 'IBK':
      case 'IBK기업':
      case '기업은행':
      case 'IBK기업은행':
      case 'IBK은행':
        return 'IBK기업';

      case '카카오':
      case '카카오뱅크':
        return '카카오';

      case '토스':
      case '토스뱅크':
        return '토스';
      
      case '케이':
      case '케이뱅크':
        return '케이';
      
      case '제일':
      case 'sc':
      case 'SC':
      case 'sc제일':
      case 'SC제일':
      case '제일은행':
      case 'sc제일은행':
      case 'SC제일은행':
      case 'SC은행':
        return 'SC제일';

      default:
        return bankName.trim();
    }
  }
}