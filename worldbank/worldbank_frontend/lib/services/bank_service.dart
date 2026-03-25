import '../models/bank_model.dart';

class BankService {
  final String accessToken;

  BankService({this.accessToken = ''});

  // 1. 공통: 잔액 확인 (국적 상관없이 호출)
  Future<ApiResponse<BalanceModel>> fetchBalance(String userId) async {
    try {
      // final response = await _dio.get(
      //   '/api/finance?userId=$userId',
      //   options: Options(headers: {'accesstoken': accessToken}),
      // );

      // 2. 가짜 응답 데이터 생성
      final mockResponseData = {
        'message': '로컬 테스트 성공',
        'data': {'amount': 55000.0, 'currency': 'KRW'},
      };

      return ApiResponse(
        // message: response.data['message'],
        // data: BalanceModel.fromJson(response.data['data']),
        message: mockResponseData['message'] as String,
        data: BalanceModel.fromJson(
          mockResponseData['data'] as Map<String, dynamic>,
        ),
      );
    } catch (e) {
      return ApiResponse(message: '잔액 조회 실패: $e');
    }
  }

  // // 2. KR 전용: 사업자 정보 조회 (다른 국적일 땐 호출 금지)
  // Future<ApiResponse<BusinessModel>> fetchBusinessInfo(
  //   String accountNumber,
  // ) async {
  //   try {
  //     final response = await _dio.get(
  //       '/api/finance/corporation/$accountNumber',
  //       options: Options(headers: {'accesstoken': accessToken}),
  //     );

  //     return ApiResponse(
  //       message: response.data['message'],
  //       data: BusinessModel.fromJson(response.data['data']),
  //     );
  //   } catch (e) {
  //     return ApiResponse(message: '사업자 조회 실패: $e');
  //   }
  // }

  // 3. 시뮬레이션: 입금 기록 생성
  Future<ApiResponse<TransactionHistory>> deposit({
    required BankNationality nationality,
    required double amount,
    required String currency,
    required BankAccount account,
    required double currentBalance,
  }) async {
    try {
      final tx = TransactionHistory(
        historyId: DateTime.now().millisecondsSinceEpoch.toString(),
        type: TransactionType.deposit,
        isCredit: true,
        counterParty: 'Deposit',
        memo: 'Simulated deposit',
        transactedAt: DateTime.now(),
        amount: amount,
        balanceAfter: currentBalance + amount,
      );
      return ApiResponse(message: '입금 시뮬레이션 완료', data: tx);
    } catch (e) {
      return ApiResponse(message: '입금 실패: $e');
    }
  }
}
