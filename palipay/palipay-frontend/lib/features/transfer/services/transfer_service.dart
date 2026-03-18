import 'package:palipay_app/features/transfer/models/transfer_model.dart';

class TransferService {
  Future<bool> executeTransfer(TransferRequest request) async {
    await Future.delayed(const Duration(seconds: 1)); // 통신 시뮬레이션
    return true; // 무조건 성공 (테스트용)
  }
}
