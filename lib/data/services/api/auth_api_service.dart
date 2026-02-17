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
  /// If role='worker', includes worker profile data.
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

      // Return full response data including token and worker profile if available
      final data = response.data as Map<String, dynamic>;
      final result = <String, dynamic>{
        'user': data['user'] as Map<String, dynamic>,
        if (data['token'] != null) 'token': data['token'] as String,
      };

      // Include worker data if present (for worker role)
      if (data.containsKey('worker')) {
        result['worker'] = data['worker'] as Map<String, dynamic>;
      }

      return result;
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

  /// Create worker account (admin only)
  ///
  /// Creates a User account with role='worker' and links it to an existing Worker.
  Future<Map<String, dynamic>> createWorkerAccount({
    required String workerId,
    required String username,
    required String password,
    String? email,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/workers/create-account/',
        data: {
          'worker_id': workerId,
          'username': username,
          'password': password,
          if (email != null) 'email': email,
        },
      );

      return response.data as Map<String, dynamic>;
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
