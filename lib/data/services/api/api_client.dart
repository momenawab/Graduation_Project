import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

/// Dio HTTP client wrapper with 30 second timeout, interceptors, and error handling.
@immutable
class ApiClient {
  /// The underlying Dio instance
  final Dio dio;

  /// Base URL for all API requests
  final String baseUrl;

  /// Default timeout for requests (30 seconds)
  static const Duration defaultTimeout = Duration(seconds: 30);

  /// Creates a new ApiClient instance.
  ///
  /// [baseUrl] is the base URL for all API requests.
  /// [timeout] is the request timeout duration (defaults to 30 seconds).
  /// [interceptors] is a list of Dio interceptors to add.
  factory ApiClient.create({
    required String baseUrl,
    Duration timeout = defaultTimeout,
    List<Interceptor> interceptors = const [],
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: timeout,
        receiveTimeout: timeout,
        sendTimeout: timeout,
        headers: {
          'Accept': 'application/json',
        },
        // Don't set Content-Type globally - Dio will set it correctly
        // based on the data type (application/json for JSON,
        // multipart/form-data with boundary for FormData)
      ),
    );

    // Add provided interceptors
    for (final interceptor in interceptors) {
      dio.interceptors.add(interceptor);
    }

    // Add logging interceptor in debug mode
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    );

    return ApiClient._(dio: dio, baseUrl: baseUrl);
  }

  /// Private constructor
  const ApiClient._({required this.dio, required this.baseUrl});

  /// Sets the auth token for all subsequent requests.
  /// Uses DRF TokenAuthentication: `Authorization: Token <key>`
  void setAuthToken(String token) {
    dio.options.headers['Authorization'] = 'Token $token';
  }

  /// Clears the auth token.
  void clearAuthToken() {
    dio.options.headers.remove('Authorization');
  }

  /// Performs a GET request.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Performs a POST request.
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Performs a PUT request.
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Performs a DELETE request.
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handles Dio exceptions and converts them to user-friendly errors.
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception(
          'Request timeout. Please check your connection and try again.',
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'An error occurred';
        return Exception('Request failed with status $statusCode: $message');

      case DioExceptionType.cancel:
        return Exception('Request was cancelled');

      case DioExceptionType.connectionError:
        return Exception(
          'No internet connection. Please check your network settings.',
        );

      case DioExceptionType.unknown:
        return Exception('An unexpected error occurred: ${error.message}');

      default:
        return Exception('An error occurred: ${error.message}');
    }
  }

  /// Closes the Dio client and releases resources.
  void close() {
    dio.close();
  }
}
