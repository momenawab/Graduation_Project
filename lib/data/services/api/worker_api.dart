import 'dart:io';
import 'package:dio/dio.dart';
import '../../models/worker.dart';
import 'api_client.dart';
import 'package:safesight/core/constants/api_constants.dart';

/// Worker API service for worker-related operations.
class WorkerApi {
  /// The API client instance
  final ApiClient apiClient;

  /// Creates a new WorkerApi instance.
  WorkerApi({required this.apiClient}) : dio = apiClient.dio;

  /// Dio instance for direct API calls
  final Dio dio;

  /// Gets a list of all workers.
  Future<List<Worker>> getWorkers() async {
    try {
      final response = await dio.get(
        ApiConstants.workers.fullPath,
      );

      if (response.statusCode == 200) {
        final body = response.data;
        // DRF may paginate ({count, next, previous, results}) or return a bare list.
        final List<dynamic> data = body is List
            ? body
            : (body is Map && body['results'] is List)
                ? body['results'] as List<dynamic>
                : const <dynamic>[];
        return data.map((json) {
          return Worker.fromJson(json as Map<String, dynamic>);
        }).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Gets a single worker by ID.
  Future<Worker> getWorker(String id) async {
    try {
      final response = await dio.get(
        '${ApiConstants.apiPath}/workers/$id/',
      );

      if (response.statusCode == 200) {
        return Worker.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Worker not found');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Creates a new worker.
  Future<Worker> createWorker(Worker worker) async {
    try {
      final response = await dio.post(
        ApiConstants.workers.fullPath,
        data: {
          'worker_id': worker.id,
          'name': worker.fullName,
          'department': worker.department,
          'position': worker.jobTitle,
          'required_ppe': worker.requiredPpe.map((e) => e.name).toList(),
        },
      );
      return Worker.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Updates an existing worker.
  /// PUT /api/workers/{id}/
  Future<Worker> updateWorker(Worker worker) async {
    try {
      final response = await dio.put(
        '${ApiConstants.apiPath}/workers/${worker.id}/',
        data: {
          'name': worker.fullName,
          'department': worker.department,
          'position': worker.jobTitle,
          'required_ppe': worker.requiredPpe.map((e) => e.name).toList(),
        },
      );
      return Worker.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Deletes a worker by ID.
  /// DELETE /api/workers/{id}/
  Future<void> deleteWorker(String id) async {
    try {
      await dio.delete('${ApiConstants.apiPath}/workers/$id/');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Gets a list of all departments.
  Future<List<String>> getDepartments() async {
    // TODO: Replace with actual API call
    // final response = await apiClient.get<List<dynamic>>('/departments');
    // return response.data.cast<String>();

    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      'Production',
      'Maintenance',
      'Safety',
      'Quality Control',
      'Logistics',
    ];
  }

  /// Gets a list of job titles.
  Future<List<String>> getJobTitles() async {
    // TODO: Replace with actual API call
    // final response = await apiClient.get<List<dynamic>>('/job-titles');
    // return response.data.cast<String>();

    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      'Operator',
      'Supervisor',
      'Technician',
      'Lead',
      'Inspector',
      'Officer',
      'Manager',
    ];
  }

  /// Gets a worker by worker_id (the custom 8-digit ID).
  Future<Map<String, dynamic>> getWorkerByWorkerId(String workerId) async {
    try {
      final response = await dio.get(
        '${ApiConstants.apiPath}${ApiConstants.workerById}$workerId/',
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Gets violations for a specific worker.
  Future<Map<String, dynamic>> getWorkerViolations(String workerId) async {
    try {
      final response = await dio.get(
        '${ApiConstants.apiPath}/workers/$workerId/violations/',
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// F4 — per-worker compliance score + streak.
  /// GET /api/workers/{worker_id}/compliance/
  Future<Map<String, dynamic>> getWorkerCompliance(String workerId) async {
    try {
      final response = await dio.get(
        '${ApiConstants.apiPath}/workers/$workerId/compliance/',
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Gets overall worker statistics for reports.
  Future<Map<String, dynamic>> getWorkerStats() async {
    try {
      final response = await dio.get(
        '${ApiConstants.apiPath}/workers/stats/',
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Gets worker violations summary for reports.
  Future<List<dynamic>> getViolationsSummary() async {
    try {
      final response = await dio.get(
        '${ApiConstants.apiPath}/workers/violations-summary/',
      );
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Creates a new worker with a face photo for face recognition.
  Future<Map<String, dynamic>> addWorkerWithPhoto({
    required String workerId,
    required String name,
    required File photo,
    String? department,
    String? position,
    List<String>? requiredPpe,
    String? email,
    String? phone,
  }) async {
    try {
      final fileBytes = await photo.readAsBytes();
      final formData = FormData.fromMap({
        'worker_id': workerId,
        'name': name,
        'photo': MultipartFile.fromBytes(
          fileBytes,
          filename: photo.path.split('/').last,
        ),
        if (department != null) 'department': department,
        if (position != null) 'position': position,
        if (requiredPpe != null) 'required_ppe': requiredPpe.join(','),
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
      });

      final response = await dio.post(
        ApiConstants.workerAddWithPhoto.fullPath,
        data: formData,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
        ),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout');

      case DioExceptionType.badResponse:
        final data = error.response?.data;
        final message = data is Map
            ? (data['detail'] ?? data['message'] ?? 'Request failed')
            : 'Request failed';
        return Exception('Error ${error.response?.statusCode}: $message');

      case DioExceptionType.cancel:
        return Exception('Request was cancelled');

      case DioExceptionType.connectionError:
        return Exception('Cannot connect to server');

      case DioExceptionType.unknown:
      default:
        return Exception('An error occurred: ${error.message}');
    }
  }
}
