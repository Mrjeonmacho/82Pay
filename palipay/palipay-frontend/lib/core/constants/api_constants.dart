class ApiConstants {
  // 1. 잔액 및 PIN 검증 (Check)
  static const String balanceCheck = '/finance/balance/check';
  static const String pinValidate = '/finance/pin/validate';
  static const String externalAccountValidate =
      '/finance/external-accounts/validate';

  // 2. 이체 관련 (Transfer)
  static const String transferValidate = '/finance/transfers/validate';
  static const String transferExecute = '/finance/transfers';

  // 이체 실패 처리 (Path Variable 포함)
  static String transferFail(String transferId) =>
      '/finance/transfers/$transferId/fail';

  // 3. 인증 및 사용자 (Auth & User)
  static const String login = '/auth/login';
  static const String signUp = '/auth/signup';
  static const String profile = '/users/profile';

  // 4. 계좌 관리
  static const String accountLink = '/users/accounts';
  // 팁: Path Variable({walletId})은 보통 서비스단에서 문자열 치환하거나 아래처럼 함수로 관리합니다.
  static String accountDelete(String walletId) => '/users/accounts/$walletId';

  static const String ocrScan = '/ai/ocr';

  // TEST
  static const String pinSet = '/pin/set';
  static const String accountBalance = '/wallet/balance';
  static const String language = '/user/language';
  static const String logout = '/auth/logout';
  static const String deleteUser = '/user/delete';
  static const String changePassword = '/user/change-password';
}
