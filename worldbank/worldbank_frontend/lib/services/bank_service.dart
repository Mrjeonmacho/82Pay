import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BankService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? "http://70.12.247.184:8080";

  // 1. 계좌 정보(잔액) 가져오기
  Future<Map<String, dynamic>?> getAccountInfo(
    int userId,
    String currency,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/finance/user/$userId?currency=$currency'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      print("계좌 조회 에러: $e");
    }
    return null;
  }

  // 2. 거래 내역 가져오기
  Future<List<dynamic>> getHistory(int userId, String currency) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/finance/history/$userId?currency=$currency'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      print("히스토리 조회 에러: $e");
    }
    return [];
  }
}
