import 'package:flutter/foundation.dart';

enum DeleteAccountResult {
  invalidPassword,
  remainingBalance,
  success,
  failure,
}

class DeleteAccountProvider extends ChangeNotifier {
  Future<DeleteAccountResult> deleteAccount({
    required String password,
  }) async {
    // TODO: 추후 회원탈퇴 API 연결
    await Future.delayed(const Duration(milliseconds: 700));
    // final response = await userRepository.deleteAccount(password: password);

    // 개발 중 테스트용 mock 분기, 추후 서버 응답에 따라 분기
    if (password == 'wrong') {
      return DeleteAccountResult.invalidPassword;
    }

    if (password == 'balance') {
      return DeleteAccountResult.remainingBalance;
    }

    if (password == 'fail') {
      return DeleteAccountResult.failure;
    }

    return DeleteAccountResult.success;
  }
}