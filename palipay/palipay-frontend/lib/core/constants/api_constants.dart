// lib/core/constants/api_constants.dart

class ApiConstants {
  // 1. 버전 관리 (필요 시)
  static const String _version = '/v1';

  // 2. 인증 관련 (Auth)
  static const String login = '$_version/auth/login';
  static const String signUp = '$_version/auth/signup';

  // 3. 계좌 관련 (Account)
  static const String accountList = '$_version/accounts';
  static const String balance = '$_version/accounts/balance';

  // 4. 거래 내역 관련 (History)
  static const String transactions = '$_version/finance/transactions';
  static String transactionDetail(int id) =>
      '$_version/finance/transactions/$id/currency';
}
