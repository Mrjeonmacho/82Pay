import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late Dio dio;
  final _storage = const FlutterSecureStorage();

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    // .env에서 BASE_URL을 읽어오고 설정 (없을 시 기본값 세팅)
    dio = Dio(BaseOptions(
      baseUrl: dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8081',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // 공통 인터셉터 설정 (모든 요청에 대해 가로채기 수행)
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 요청 보내기 전에 기기에 저장된 액세스 토큰 찾아오기
          final token = await _storage.read(key: 'accessToken');
          if (token != null) {
            // 명세서에 나와있는 대로 'accesstoken' 키에 값을 담아 전송
            options.headers['accesstoken'] = token;
          }
          return handler.next(options); // 다음 단계로 요청 패스
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          // 보통 401(Unauthorized)이 오면 여기서 Refresh Token으로 갱신 로직 추가 등을 수행
          // 현재는 그대로 에러 반환
          return handler.next(e);
        },
      ),
    );
  }
}
