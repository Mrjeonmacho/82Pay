import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:palipay_app/core/constants/api_constants.dart';
import 'package:palipay_app/core/network/dio_client.dart';

import '../models/scan_result_model.dart';

class ScanService {
  final Dio _dio = DioClient().dio;

  Future<ScanResultModel> uploadForOcr(File imageFile) async {
    try {
      final fileName = imageFile.path.split('/').last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(ApiConstants.ocrScan, data: formData);

      return ScanResultModel.fromJson(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      return ScanResultModel.failure(_handleError(e));
    } catch (_) {
      return ScanResultModel.failure('예상치 못한 오류가 발생했습니다.');
    }
  }

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
