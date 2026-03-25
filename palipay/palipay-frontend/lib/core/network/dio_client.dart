import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // 웹 체크용
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late Dio dio;
  final _storage = const FlutterSecureStorage();

  // 임시 가상 잔액 (Mock)
  double _mockCurrentBalance = 50000.0;
  
  // 임시 거래 내역 (Mock)
  final List<Map<String, dynamic>> _mockTransactions = [];

  // 쿠키 저장소를 나중에 초기화하기 위해 late로 선언
  // 더 넓은 의미인 'CookieJar'로 변경
  late CookieJar cookieJar;

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    // .env에서 BASE_URL을 읽어오고 설정 (없을 시 기본값 세팅)
    dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8081',
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  // 핵심: 비동기 초기화 함수 추가
  Future<void> init() async {
    // 웹과 모바일 분기 처리 (getApplicationDocumentsDirectory을 사용하면 웹에서 오류 발생)
    if (kIsWeb) {
      // 1. 웹: 메모리 쿠키 저장소 사용 (파일 경로 필요 없음)
      cookieJar = CookieJar();
      print("Web 환경: 메모리 쿠키 저장소를 사용합니다.");
    } else {
      // 1. 저장 경로 설정
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;

      // 2. 영구 쿠키 저장소 생성
      cookieJar = PersistCookieJar(
        ignoreExpires: false,
        storage: FileStorage("$appDocPath/.cookies/"),
      );

      // 3. 쿠키 매니저 인터셉터 추가
      dio.interceptors.add(CookieManager(cookieJar));

      // 4. 기존 인터셉터 설정 (순서상 쿠키 매니저 뒤에 붙여도 무방함)
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            // ========================================================================
            // 💡 [MOCK INTERCEPTOR]
            // 현재 8080포트(worldbank) 접속 불가로 인해 백엔드(/wallet/accounts)가 타임아웃을 냅니다.
            // 따라서 프론트엔드 개발 진행을 위해 여기서 가로채서 성공 응답을 내려줍니다.
            if (options.path.contains('/wallet/accounts')) {
              print('🚀 [MOCK] Intercepted /wallet/accounts Request');
              
              // 입력한 비밀번호 확인
              final payload = options.data as Map<String, dynamic>?;
              final inputPassword = payload?['accountPassword'];

              // 가짜 비밀번호 검증 (1234일 때만 성공)
              if (inputPassword == '1234') {
                return handler.resolve(
                  Response(
                    requestOptions: options,
                    statusCode: 200,
                    data: {
                      "status": "success",
                      "walletId": 1,
                      "bankName": "WorldBank",
                      "accountUsername": "JAMES",
                      "accountNumber": "110-96",
                      "amount": 0
                    },
                  ),
                );
              } else {
                // 비밀번호 틀림 시 실패 응답
                return handler.resolve(
                  Response(
                    requestOptions: options,
                    statusCode: 200,
                    data: {
                      "status": "fail",
                      "walletId": 1,
                      "message": "Invalid password"
                    },
                  ),
                );
              }
            } else if (options.path.contains('/finance/balance/check')) {
              print('🚀 [MOCK] Intercepted /finance/balance/check Request');
              final payload = options.data as Map<String, dynamic>?;
              final amount = payload?['amount'] ?? 0;
              final isSufficient = _mockCurrentBalance >= amount;

              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    "message": isSufficient ? "잔액이 충분합니다." : "잔액이 부족합니다.",
                    "data": {
                      "isSufficient": isSufficient,
                      "currentBalance": _mockCurrentBalance,
                      "requiredAmount": amount,
                      "shortageAmount": isSufficient ? 0 : amount - _mockCurrentBalance
                    }
                  },
                ),
              );
            } else if (options.path.contains('/finance/charges')) {
              print('🚀 [MOCK] Intercepted /finance/charges Request');
              final payload = options.data as Map<String, dynamic>?;
              final amount = payload?['convertedAmount'] ?? 10000;
              
              _mockCurrentBalance += amount; // 잔액 증가
              
              final newTxId = 9100 + _mockTransactions.length;
              final now = DateTime.now().toIso8601String();
              
              _mockTransactions.insert(0, {
                "transactionId": newTxId,
                "category": "INPUT",
                "amount": amount,
                "exchangeAfterAmount": amount, // Mock
                "exchangeRate": 1340.5,
                "otherAccountNumber": "",
                "otherAccountName": "Wallet Top-up",
                "otherBankCode": "",
                "workplaceId": 0,
                "createdAt": now,
                "description": "지갑 충전"
              });

              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    "message": "충전이 완료되었습니다. (Mock)",
                    "data": {
                      "transactionId": 9100,
                      "chargedAmount": amount,
                      "exchangeRate": 1340.5,
                      "currentBalance": _mockCurrentBalance,
                      "createdAt": DateTime.now().toIso8601String()
                    }
                  },
                ),
              );
            } else if (options.path.contains('/finance/refunds/max')) {
              print('🚀 [MOCK] Intercepted /finance/refunds/max Request');
              // 가상 지갑에 있는 금액에서 소정의 수수료(e.g., 0 KRW)를 뺀 금액을 최대 환불 가능 금액으로 설정
              final feeAmount = 0;
              final maxRefundable = (_mockCurrentBalance - feeAmount > 0) 
                  ? _mockCurrentBalance - feeAmount 
                  : 0;

              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    "message": "환불 가능 금액 조회에 성공했습니다. (Mock)",
                    "data": {
                      "walletId": 101,
                      "currentBalance": _mockCurrentBalance,
                      "maxRefundableAmount": maxRefundable, 
                      "feeAmount": feeAmount,
                      "reason": "수수료 차감"
                    }
                  },
                ),
              );
            } else if (options.path.contains('/finance/refunds')) {
              print('🚀 [MOCK] Intercepted /finance/refunds Request');
              final payload = options.data as Map<String, dynamic>?;
              final amount = payload?['convertedAmount'] ?? 10000;
              
              if (_mockCurrentBalance >= amount) {
                _mockCurrentBalance -= amount;
                
                final newTxId = 9100 + _mockTransactions.length;
                final now = DateTime.now().toIso8601String();
                
                _mockTransactions.insert(0, {
                  "transactionId": newTxId,
                  "category": "OUTPUT",
                  "amount": amount,
                  "exchangeAfterAmount": amount,
                  "exchangeRate": 1340.5,
                  "otherAccountNumber": "",
                  "otherAccountName": "Wallet Refund",
                  "otherBankCode": "",
                  "workplaceId": 0,
                  "createdAt": now,
                  "description": "지갑 환급"
                });
              }
              
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    "message": "환급이 완료되었습니다. (Mock)",
                    "data": {
                      "transactionId": 9101,
                      "afterAmount": amount,
                      "exchangeRate": 1340.5,
                      "currentBalance": _mockCurrentBalance,
                      "createdAt": DateTime.now().toIso8601String()
                    }
                  },
                ),
              );
            } else if (options.path.contains('/finance/quote')) {
              print('🚀 [MOCK] Intercepted /finance/quote Request');
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    "message": "환율 견적이 생성되었습니다.",
                    "data": {
                      "quoteId": "q_1a2b3c",
                      "exchangeRate": 1340.5,
                      "rateTimestamp": DateTime.now().toIso8601String()
                    }
                  },
                ),
              );
            } else if (options.path.contains('/finance/transactions')) {
              print('🚀 [MOCK] Intercepted /finance/transactions Request');
              
              // 필터링 처리 로직 (간이 구현)
              String? category = options.queryParameters['category'];
              List<Map<String, dynamic>> filtered = _mockTransactions;
              if (category != null && category.isNotEmpty && category != 'ALL') {
                filtered = _mockTransactions.where((t) => t['category'] == category).toList();
              }
              
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    "message": "거래 내역 조회 완료",
                    "data": {
                      "items": filtered,
                      "page": {
                        "page": 0,
                        "size": 20,
                        "totalElements": filtered.length,
                        "totalPages": 1
                      }
                    }
                  },
                ),
              );
            }
            // ========================================================================

            final token = await _storage.read(key: 'accessToken');
            final grantType = await _storage.read(key: 'grantType') ?? 'Bearer';
            if (token != null) {
              options.headers['Authorization'] = '$grantType $token';
            }
            return handler.next(options);
          },
          onError: (DioException e, handler) async {
            // 여기에 401 에러 시 RT를 이용한 토큰 재발급 로직을 넣으시면 됩니다.
            return handler.next(e);
          },
        ),
      );
    }
  }
}
