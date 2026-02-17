import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../api/api_client.dart';
import 'package:safesight/core/constants/api_constants.dart';

/// Authentication API service for communicating with Django backend.
class AuthApiService {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// User login
  ///
  /// Returns user data on success, throws exception on failure.
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.login.fullPath,
        data: {
          'username': username,
          'password': password,
        },
      );

      return response.data['user'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// User registration
  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String passwordConfirm,
    String? email,
    String? firstName,
    String? lastName,
    String? role,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.register.fullPath,
        data: {
          'username': username,
          'password': password,
          'password_confirm': passwordConfirm,
          if (email != null) 'email': email,
          if (firstName != null) 'first_name': firstName,
          if (lastName != null) 'last_name': lastName,
          if (role != null) 'role': role,
        },
      );

      return response.data['user'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// User logout
  Future<void> logout() async {
    try {
      await _apiClient.dio.post(
        ApiConstants.logout.fullPath,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get current user profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.profile.fullPath,
      );

      return response.data['user'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Change password
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _apiClient.dio.post(
        '${ApiConstants.profile.fullPath}change-password/',
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
          'new_password_confirm': newPassword,
        },
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Please check your network.');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['detail'] ??
            error.response?.data?['message'] ??
            error.response?.data?['password'] ??
            'Request failed';
        return Exception('Error $statusCode: $message');

      case DioExceptionType.cancel:
        return Exception('Request was cancelled');

      case DioExceptionType.connectionError:
        return Exception(
            'Cannot connect to server. Make sure the backend is running at ${ApiConstants.baseUrl}');

      case DioExceptionType.unknown:
      default:
        return Exception('An error occurred: ${error.message}');
    }
  }
}
