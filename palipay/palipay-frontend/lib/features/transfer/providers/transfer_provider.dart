import 'package:flutter/material.dart';
import '../models/transfer_model.dart';
import '../services/transfer_service.dart';

class TransferProvider extends ChangeNotifier {
  final TransferService _service = TransferService();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> sendMoney(TransferRequest request) async {
    _isLoading = true;
    notifyListeners();

    final success = await _service.executeTransfer(request);

    _isLoading = false;
    notifyListeners();
    return success;
  }
}
