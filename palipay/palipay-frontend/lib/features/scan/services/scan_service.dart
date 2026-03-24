import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:palipay_app/core/constants/api_constants.dart';
import 'package:palipay_app/core/network/dio_client.dart';

import '../models/scan_result_model.dart';

class ScanService {
  final Dio _dio = DioClient().dio;

  ScanService();

  Future<ScanResultModel> uploadForOcr(File imageFile) async {
    try {
      final fileName = imageFile.path.split('/').last;
      final requestPath = ApiConstants.ocrScan;
      final fullUrl = '${_dio.options.baseUrl}$requestPath';

      debugPrint('=== OCR REQUEST START ===');
      debugPrint('baseUrl: ${_dio.options.baseUrl}');
      debugPrint('path: $requestPath');
      debugPrint('fullUrl: $fullUrl');
      debugPrint('method: POST');
      debugPrint('fileName: $fileName');
      debugPrint('exists: ${await imageFile.exists()}');
      debugPrint('size: ${await imageFile.length()}');

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        requestPath,
        data: formData,
      );

      debugPrint('=== OCR RESPONSE STATUS === ${response.statusCode}');
      debugPrint('=== OCR RESPONSE DATA === ${response.data}');

      return ScanResultModel.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      debugPrint('=== OCR DIO ERROR ===');
      debugPrint('request method: ${e.requestOptions.method}');
      debugPrint('request uri: ${e.requestOptions.uri}');
      debugPrint('statusCode: ${e.response?.statusCode}');
      debugPrint('responseData: ${e.response?.data}');
      return ScanResultModel.failure(_handleError(e));
    } catch (e) {
      debugPrint('=== OCR UNKNOWN ERROR === $e');
      return ScanResultModel.failure('예상치 못한 오류가 발생했습니다: $e');
    }
  }

  // Future<ScanResultModel> uploadForOcr(File imageFile) async {
  //   try {
  //     final fileName = imageFile.path.split('/').last;

  //     debugPrint('=== OCR REQUEST START ===');
  //     debugPrint('path: ${imageFile.path}');
  //     debugPrint('fileName: $fileName');
  //     debugPrint('exists: ${await imageFile.exists()}');
  //     debugPrint('size: ${await imageFile.length()}');

  //     final formData = FormData.fromMap({
  //       'file': await MultipartFile.fromFile(
  //         imageFile.path,
  //         filename: fileName,
  //       ),
  //     });

  //     final response = await _dio.patch(
  //       ApiConstants.ocrScan,
  //       data: formData,
  //     );

  //     debugPrint('=== OCR RESPONSE STATUS === ${response.statusCode}');
  //     debugPrint('=== OCR RESPONSE DATA === ${response.data}');

  //     return ScanResultModel.fromJson(
  //       Map<String, dynamic>.from(response.data),
  //     );
  //   } on DioException catch (e) {
  //     debugPrint('=== OCR DIO ERROR ===');
  //     debugPrint('message: ${e.message}');
  //     debugPrint('statusCode: ${e.response?.statusCode}');
  //     debugPrint('responseData: ${e.response?.data}');
  //     return ScanResultModel.failure(_handleError(e));
  //   } catch (e) {
  //     debugPrint('=== OCR UNKNOWN ERROR === $e');
  //     return ScanResultModel.failure('예상치 못한 오류가 발생했습니다: $e');
  //   }
  // }

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        return data['message']?.toString() ??
            data['error']?.toString() ??
            '서버 오류가 발생했습니다.';
      }

      return '서버 오류가 발생했습니다. (${e.response?.statusCode})';
    }

    return '서버와 통신 중 네트워크 오류가 발생했습니다.';
  }
}