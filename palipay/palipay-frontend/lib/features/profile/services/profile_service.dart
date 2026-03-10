import 'package:dio/dio.dart';
import '../models/profile_user_model.dart';

class ProfileService {
  final Dio _dio = Dio(
    BaseOptions(baseUrl: 'http://localhost:3000'),
  );

  /// 사용자 프로필 조회
  Future<ProfileUserModel> getProfile() async {
    try {
      final response = await _dio.get('/api/users/profile');

      return ProfileUserModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// 언어 변경
  Future<Response> updateLanguage(String language) async {
    try {
      return await _dio.patch(
        '/api/users/language',
        data: {'language': language},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 로그아웃
  Future<Response> logout() async {
    try {
      return await _dio.post('/api/auth/logout');
    } catch (e) {
      rethrow;
    }
  }

  /// 회원탈퇴
  Future<Response> deleteAccount() async {
    try {
      return await _dio.delete('/api/users');
    } catch (e) {
      rethrow;
    }
  }
}