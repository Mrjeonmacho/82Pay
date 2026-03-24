import 'package:dio/dio.dart';

import '../../../core/config/env_config.dart';
import '../../../core/constants/api_constants.dart';
import '../models/profile_user_model.dart';

class ProfileService {
  final Dio _dio = Dio(
    BaseOptions(baseUrl: EnvConfig.baseUrl),
  );

  /// Fetch user profile
  Future<ProfileUserModel> getProfile() async {
    try {
      final response = await _dio.get(ApiConstants.profile);
      return ProfileUserModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update language
  Future<Response> updateLanguage(String language) async {
    try {
      return await _dio.patch(
        ApiConstants.language,
        data: {'language': language},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Logout
  Future<Response> logout() async {
    try {
      return await _dio.post(ApiConstants.logout);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete account
  Future<Response> deleteAccount() async {
    try {
      return await _dio.delete(ApiConstants.deleteUser);
    } catch (e) {
      rethrow;
    }
  }

  /// Change password
  Future<Response> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      // TODO: Replace with actual API request when backend is ready
      // return await _dio.patch(
      //   ApiConstants.changePassword,
      //   data: {
      //     'oldPassword': oldPassword,
      //     'newPassword': newPassword,
      //   },
      // );

      await Future.delayed(const Duration(milliseconds: 800));

      return Response(
        requestOptions: RequestOptions(path: ApiConstants.changePassword),
        statusCode: 200,
        data: {
          'message': 'Password changed successfully (mock)',
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}