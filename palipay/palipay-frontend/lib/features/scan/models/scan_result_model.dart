class ScanResultModel {
  final bool success;
  final String? bankName;
  final String? accountNumber;
  final String? rawText;
  final String? message;

  const ScanResultModel({
    required this.success,
    this.bankName,
    this.accountNumber,
    this.rawText,
    this.message,
  });

  factory ScanResultModel.failure({String? message}) {
    return ScanResultModel(
      success: false,
      message: message,
    );
  }
}