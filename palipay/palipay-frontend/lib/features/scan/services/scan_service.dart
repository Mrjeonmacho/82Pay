import 'dart:io';
import 'package:dio/dio.dart';
import '../models/scan_result_model.dart';

class ScanService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://your-server-url.com',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  Future<ScanResultModel> uploadForOcr(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _dio.post('/ocr/account', data: formData);
      final data = response.data;

      return ScanResultModel(
        success: data['success'] == true,
        bankName: data['bank_name'],
        accountNumber: data['account_number'],
        rawText: data['raw_text'],
        message: data['message'],
      );
    } catch (e) {
      return ScanResultModel.failure(
        message: 'OCR request failed.',
      );
    }
  }

  /// 서버 연결 전 테스트용
  Future<ScanResultModel> uploadDummy(File imageFile) async {
    await Future.delayed(const Duration(seconds: 2));

    final fileName = imageFile.path.toLowerCase();

    if (fileName.contains('fail')) {
      return ScanResultModel.failure(
        message: 'Account number could not be recognized.',
      );
    }

    return const ScanResultModel(
      success: true,
      bankName: 'KB 국민',
      accountNumber: '123-456-789012',
      rawText: 'KB 123456789012',
      message: 'Recognition success',
    );
  }
}