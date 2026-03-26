import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
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
        // headers: {'Content-Type': 'application/json'},
      ),
    );
    dio.interceptors.add(CustomLogInterceptor());
  }

  // 핵심: 비동기 초기화 함수 추가
  Future<void> init() async {
    // 웹과 모바일 분기 처리 (getApplicationDocumentsDirectory을 사용하면 웹에서 오류 발생)
    if (kIsWeb) {
      dio.options.extra['withCredentials'] = true; // 쿠키 공유 허용
      // 1. 웹: 메모리 쿠키 저장소 사용 (파일 경로 필요 없음)
      cookieJar = CookieJar();
      debugPrint("🌐 Web 환경: 메모리 쿠키 저장소를 사용합니다.");

      // 🔍 Web 환경에서도 인터셉터 추가
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            // storage에서 읽기 전, 혹시 값이 비어있는지 체크
            final token = await _storage.read(key: 'accessToken');

            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
              options.headers['accesstoken'] = token;
              debugPrint('🌐 [Web Request] Token injected from Storage');
            }
            return handler.next(options);
          },
          onError: (DioException e, handler) async {
            debugPrint('❌ [API Error - Web] ${e.message}');
            return handler.next(e);
          },
        ),
      );
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
      // 2. [수정] 공통 인터셉터 - 여기서 '무조건 성공' 로직을 처리합니다.
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            // 일반 요청일 경우 토큰 주입
            final token = await _storage.read(key: 'accessToken');
            final grantType = await _storage.read(key: 'grantType') ?? 'Bearer';
            if (token != null) {
              options.headers['Authorization'] = '$grantType $token';
              options.headers['accesstoken'] = token; // 백엔드에서 필요하다면 별도 헤더로도 전달

              // 🔍 DEBUG: 터미널에 accessToken 로깅
              debugPrint('🔐 [API Request] AccessToken: $token');
              debugPrint('📍 [API Request] URL: ${options.path}');
              debugPrint('📦 [API Request] Method: ${options.method}');
            } else {
              debugPrint('⚠️ [API Request] No AccessToken found!');
            }
            return handler.next(options);
          },
          onError: (DioException e, handler) async {
            debugPrint('❌ [API Error] ${e.message}');
            return handler.next(e);
          },
        ),
      );
    }
  }
}

class CustomLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint(
      '🚀 [API Request] ${options.method} | ${options.baseUrl}${options.path}',
    );
    debugPrint('📂 QueryParams: ${options.queryParameters}');
    debugPrint('📦 Body: ${options.data}');
    debugPrint(
      '🔐 Headers: ${options.headers['Authorization'] != null ? "Token Exist" : "No Token"}',
    );
    debugPrint('------------------------------------------------------------');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
      '✅ [API Response] ${response.statusCode} | ${response.requestOptions.path}',
    );
    debugPrint('📩 Data: ${response.data}');
    debugPrint('------------------------------------------------------------');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '❌ [API Error] ${err.response?.statusCode} | ${err.requestOptions.path}',
    );
    debugPrint('⚠️ Message: ${err.message}');
    debugPrint('💣 Error Data: ${err.response?.data}');
    debugPrint('------------------------------------------------------------');
    super.onError(err, handler);
  }
}
