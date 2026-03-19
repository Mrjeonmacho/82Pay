class ApiConstants {
  // 1. 버전 관리
  // static const String _version = '/v1';

  // 2. 인증 관련 (Auth)
  static const String login = '/auth/login';
  static const String signUp = '/auth/signup';

  // 3. 외부 계좌 관련 (Account)
  static const String accountLink = '/users/accounts';
  static const String accountDelete = '/users/accounts/{walletId}';
  static const String pinSet = '/users/pin';
  static const String accountBalance = '/finance/balance/check';
  static String accountBalanceInsufficient(int amount) =>
      '/finance/balance/check?amount=$amount';

  // 등 필요한 API 엔드포인트를 여기에 추가
  // 4. Profile - 추후 API 확정되면 맞게 수정
  static const String profile = '/users/profile';
  static const String language = '/users/language';
  static const String logout = '/auth/logout';
  static const String deleteUser = '/users';
  static const String changePassword = '/users/password';
}
