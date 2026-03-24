import 'dart:io';
import 'package:flutter/material.dart';
import '../models/scan_result_model.dart';
import '../services/scan_service.dart';

enum ScanStatus {
  idle,
  scanning,
  success,
  failure,
}

class ScanProvider extends ChangeNotifier {
  final ScanService _service = ScanService();

  ScanStatus status = ScanStatus.idle;
  bool flashOn = false;
  ScanResultModel? result;

  bool get isBusy => status == ScanStatus.scanning;

  Future<void> processImage(File imageFile) async {
  status = ScanStatus.scanning;
  result = null;
  notifyListeners();

  final response = await _service.uploadForOcr(imageFile);

  debugPrint('=== OCR PARSED RESULT ===');
  debugPrint('success: ${response.success}');
  debugPrint('bankName: ${response.bankName}');
  debugPrint('accountNumber: ${response.accountNumber}');
  debugPrint('errorMessage: ${response.errorMessage}');

  result = response;
  status = response.success ? ScanStatus.success : ScanStatus.failure;
  notifyListeners();
}

//   Future<void> processImage(File imageFile) async {
//     status = ScanStatus.scanning;
//     result = null;
//     notifyListeners();

//     final response = await _service.uploadForOcr(imageFile);

//     result = response;
//     status = response.success ? ScanStatus.success : ScanStatus.failure;
//     notifyListeners();
//   }

  void toggleFlash() {
    flashOn = !flashOn;
    notifyListeners();
  }

  void reset() {
    status = ScanStatus.idle;
    result = null;
    notifyListeners();
  }
}