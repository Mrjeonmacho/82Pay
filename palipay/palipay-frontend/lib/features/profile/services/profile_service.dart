import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/profile_user_model.dart';

class ProfileService {
  final Dio _dio = DioClient().dio;

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
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _dio.patch(
      ApiConstants.changePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
  }
}