import 'package:dio/dio.dart'; // 혹은 http 패키지
import '../models/bank_account_model.dart';

class AccountService {
  // final Dio _dio = Dio(BaseOptions(baseUrl: 'https://api.palipay.com'));

  // mock 서버 등록
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));

  // 1. 계좌 등록 (POST /api/users/accounts)
  Future<Response> linkAccount(Map<String, dynamic> data) async {
    try {
      // data에는 bankName, accountNumber, countryCode, accountPassword가 포함됨
      return await _dio.post('/api/users/accounts', data: data);
    } catch (e) {
      rethrow;
    }
  }

  // 2. 계좌 삭제 (DELETE /api/users/accounts/{accountId})
  Future<Response> unlinkAccount(String accountId) async {
    try {
      return await _dio.delete('/api/users/accounts/$accountId');
    } catch (e) {
      rethrow;
    }
  }

  // 3. PIN 번호 생성/수정 (POST, PATCH /api/users/pin)
  Future<Response> managePin(String pin, {bool isUpdate = false}) async {
    try {
      if (isUpdate) {
        return await _dio.patch('/api/users/pin', data: {'pin': pin});
      }
      return await _dio.post('/api/users/pin', data: {'pin': pin});
    } catch (e) {
      rethrow;
    }
  }
}
