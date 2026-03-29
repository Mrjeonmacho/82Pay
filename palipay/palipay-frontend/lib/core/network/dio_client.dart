// lib/core/network/dio_client.dart

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint, kDebugMode;
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late Dio dio;
  final _storage = const FlutterSecureStorage();
  late CookieJar cookieJar;

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8081',
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  /// 🚀 앱 시작 시 Dio 초기화 (쿠키 및 공통 인터셉터 설정)
  Future<void> init() async {
    // 1. 쿠키 저장소 설정
    if (kIsWeb) {
      dio.options.extra['withCredentials'] = true;
      cookieJar = CookieJar();
    } else {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      cookieJar = PersistCookieJar(
        ignoreExpires: false,
        storage: FileStorage("${appDocDir.path}/.cookies/"),
      );
      dio.interceptors.add(CookieManager(cookieJar));
    }

    // 2. 공통 인증 & 언어 인터셉터 추가
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'accessToken');
          debugPrint('🔑 읽힌 토큰: $token'); // null인지 확인

          final countryCode = await _storage.read(key: 'countryCode') ?? 'US';

          // 🌐 2. 서버에 언어 설정 전달 (Accept-Language)
          const langMap = {'JP': 'ja', 'CN': 'zh', 'US': 'en'};
          options.headers['Accept-Language'] = langMap[countryCode] ?? 'en';

          final isAuthPath =
              options.path == '/auth/login' || options.path == '/auth/reissue';

          // 🔐 3. 토큰 주입 (auth 경로 제외)
          if (token != null && token.isNotEmpty && !isAuthPath) {
            options.headers['Authorization'] = 'Bearer $token';
            options.headers['accesstoken'] = token; // 백엔드가 읽는 헤더 추가

            // options.headers['accessToken'] = token;
          }

          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          debugPrint(
            '❌ [API Error] ${e.response?.statusCode} | ${e.requestOptions.path}',
          );

          if (kDebugMode) {
            debugPrint('👉 METHOD: ${e.requestOptions.method}');
            debugPrint('👉 REQUEST DATA: ${e.requestOptions.data}');
            debugPrint('👉 HEADERS: ${e.requestOptions.headers}');
            debugPrint('👉 RESPONSE DATA: ${e.response?.data}');
            debugPrint('👉 ERROR TYPE: ${e.type}');
            debugPrint('👉 MESSAGE: ${e.message}');
            debugPrint('────────────────────────────');
          }

          return handler.next(e);
        },
      ),
    );

    // 🔍 개발 환경일 때만 로그 인터셉터 추가
    if (kDebugMode) {
      dio.interceptors.add(CustomLogInterceptor());
    }
  }
}

/// 📋 상세 로그 출력용 인터셉터
class CustomLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint(
      '🚀 [API] ${options.method} ${options.path} | Lang: ${options.headers['Accept-Language']}',
    );
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('✅ [Response] ${response.statusCode}');
    super.onResponse(response, handler);
  }
}
