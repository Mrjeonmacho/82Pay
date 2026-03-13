import 'package:flutter/material.dart';
import '../services/pin_service.dart';
import '../models/pin_request_dto.dart';

enum PinStatus { idle, loading, success, failure, mismatch }

class PinProvider extends ChangeNotifier {
  final PinService _service = PinService();

  String _inputPin = "";
  PinStatus _status = PinStatus.idle;
  String? _errorMessage;

  // Getters
  String get inputPin => _inputPin;
  int get pinLength => _inputPin.length;
  PinStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isFull => _inputPin.length == 6;
  bool get isLoading => _status == PinStatus.loading;

  /// 1. 숫자 입력 (키패드 연동)
  void addDigit(String digit) {
    if (_inputPin.length < 6) {
      _inputPin += digit;
      _errorMessage = null; // 입력 중에는 에러 메시지 초기화
      notifyListeners();
    }
  }

  /// 2. 숫자 삭제 (백스페이스)
  void removeDigit() {
    if (_inputPin.isNotEmpty) {
      _inputPin = _inputPin.substring(0, _inputPin.length - 1);
      notifyListeners();
    }
  }

  /// 3. 상태 초기화
  void clear() {
    _inputPin = "";
    _status = PinStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  /// 4. PIN 검증 요청 (결제/송금 시)
  Future<bool> verifyPin(int walletId, {String? pinNumber}) async {
    final targetPin = pinNumber ?? _inputPin;

    if (targetPin.length != 6) return false;

    _status = PinStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final isSuccess = await _service.verifyPin(walletId, targetPin);

      if (isSuccess) {
        _status = PinStatus.success;
      } else {
        _status = PinStatus.failure;
        _errorMessage = "PIN number does not match.";
        if (pinNumber == null) {
          _inputPin = "";
        }
      }
      notifyListeners();
      return isSuccess;
    } catch (e) {
      _status = PinStatus.failure;
      _errorMessage = "An error occurred while communicating with the server.";
      notifyListeners();
      return false;
    }
  }

  /// 5. PIN 생성 요청 (최초 설정 시)
  Future<bool> createPin(int walletId) async {
    _status = PinStatus.loading;
    notifyListeners();

    final request = PinCreateRequest(walletId: walletId, pinNumber: _inputPin);
    final isSuccess = await _service.createPin(request);

    _status = isSuccess ? PinStatus.success : PinStatus.failure;
    if (!isSuccess) _errorMessage = "PIN 설정에 실패했습니다.";

    notifyListeners();
    return isSuccess;
  }

  // 6. PIN 수정 요청
  Future<bool> updatePin({
    required int walletId,
    required String oldPinNumber,
    required String newPinNumber,
  }) async {
    _status = PinStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = PinUpdateRequest(
        walletId: walletId,
        oldPinNumber: oldPinNumber,
        newPinNumber: newPinNumber,
      );

      final isSuccess = await _service.updatePin(request);

      if (isSuccess) {
        _status = PinStatus.success;
      } else {
        _status = PinStatus.failure;
        _errorMessage = "Failed to change PIN.";
      }

      notifyListeners();
      return isSuccess;
    } catch (e) {
      _status = PinStatus.failure;
      _errorMessage = "An error occurred while communicating with the server.";
      notifyListeners();
      return false;
    }
  }
}
