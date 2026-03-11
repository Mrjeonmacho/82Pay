// lib/core/config/env_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'http://localhost:8080';
}

// 사용 시: 
// final dio = Dio(BaseOptions(baseUrl: EnvConfig.baseUrl));