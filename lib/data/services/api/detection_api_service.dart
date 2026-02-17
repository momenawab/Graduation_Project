import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart' as getx;
import '../api/api_client.dart';
import 'package:safesight/core/constants/api_constants.dart';
import '../../models/detection_result.dart';
import '../../models/ppe_item.dart';

/// Detection API service for communicating with Django backend.
class DetectionApiService {
  final ApiClient _apiClient = getx.Get.find<ApiClient>();

  /// Upload an image for PPE detection.
  ///
  /// Returns a [DetectionResult] with the analysis data.
  Future<DetectionResult> uploadImageForDetection(File imageFile) async {
    try {
      print('🔵 [API] Uploading image to: ${ApiConstants.baseUrl}${ApiConstants.detectionUpload.fullPath}');

      // Verify file exists before uploading
      if (!imageFile.existsSync()) {
        print('🔴 [API] Image file does not exist: ${imageFile.path}');
        throw Exception('Image file does not exist: ${imageFile.path}');
      }

      final fileBytes = await imageFile.readAsBytes();
      print('🔵 [API] Image size: ${fileBytes.length} bytes');

      final formData = dio.FormData.fromMap({
        'image': dio.MultipartFile.fromBytes(
          fileBytes,
          filename: imageFile.path.split('/').last,
        ),
      });

      print('🔵 [API] Sending POST request...');
      final response = await _apiClient.dio.post(
        ApiConstants.detectionUpload.fullPath,
        data: formData,
        options: dio.Options(
          contentType: dio.Headers.multipartFormDataContentType,
        ),
      );

      print('🟢 [API] Response received: ${response.statusCode}');
      return _parseDetectionResponse(response.data);
    } on dio.DioException catch (e) {
      print('🔴 [API] DioException: ${e.type}');
      print('🔴 [API] Error message: ${e.message}');
      print('🔴 [API] Response: ${e.response?.data}');
      throw _handleDioError(e);
    } catch (e) {
      print('🔴 [API] Unexpected error: $e');
      rethrow;
    }
  }

  /// Upload image bytes for PPE detection (for camera stream).
  Future<DetectionResult> uploadImageBytes(List<int> imageBytes) async {
    try {
      final formData = dio.FormData.fromMap({
        'image': dio.MultipartFile.fromBytes(
          imageBytes,
          filename: 'camera_frame.jpg',
        ),
      });

      final response = await _apiClient.dio.post(
        ApiConstants.detectionUpload.fullPath,
        data: formData,
      );

      return _parseDetectionResponse(response.data);
    } on dio.DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get detection records.
  Future<List<Map<String, dynamic>>> getDetectionRecords({
    String? sessionId,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      if (sessionId != null) {
        queryParams['session_id'] = sessionId;
      }
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }

      final response = await _apiClient.dio.get(
        ApiConstants.detectionRecords.fullPath,
        queryParameters: queryParams,
      );

      final data = response.data as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(
        data['results'] as List,
      );
    } on dio.DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get violation records.
  Future<List<Map<String, dynamic>>> getViolationRecords({
    String? workerId,
    String? status,
    String? severity,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      if (workerId != null) {
        queryParams['worker_id'] = workerId;
      }
      if (status != null) {
        queryParams['status'] = status;
      }
      if (severity != null) {
        queryParams['severity'] = severity;
      }
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }

      final response = await _apiClient.dio.get(
        ApiConstants.detectionViolations.fullPath,
        queryParameters: queryParams,
      );

      final data = response.data as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(
        data['results'] as List,
      );
    } on dio.DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Check backend health.
  Future<bool> checkHealth() async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.detectionHealth.fullPath,
      );
      return response.data['status'] == 'healthy' &&
          response.data['model_loaded'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Create a new detection session.
  Future<String> createSession({
    String? location,
    String? cameraId,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.detectionSessions.fullPath + 'create/',
        data: {
          if (location != null) 'location': location,
          if (cameraId != null) 'camera_id': cameraId,
        },
      );

      return response.data['session_id'] as String;
    } on dio.DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// End a detection session.
  Future<void> endSession(String sessionId) async {
    try {
      await _apiClient.dio.post(
        '${ApiConstants.detectionSessions.fullPath}$sessionId/end/',
      );
    } on dio.DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Parse detection response from backend.
  DetectionResult _parseDetectionResponse(dynamic data) {
    final detectionsList = data['detections'] as List? ?? [];

    final detections = detectionsList.map((d) {
      final detection = d as Map<String, dynamic>;
      final ppeStatusList = detection['ppeStatus'] as List? ?? [];

      return PersonDetection(
        workerId: detection['workerId'] as String?,
        boundingBox: BoundingBox.fromJson(
          detection['boundingBox'] as Map<String, dynamic>,
        ),
        ppeStatus: ppeStatusList.map((ppe) {
          final item = ppe as Map<String, dynamic>;
          return PPEItem(
            type: _parsePPEType(item['type'] as String),
            status: _parsePPEStatus(item['status'] as String),
            lastDetected: item['lastDetected'] != null
                ? DateTime.tryParse(item['lastDetected'] as String)
                : null,
          );
        }).toList(),
        overallStatus: _parseOverallStatus(
          detection['overallStatus'] as String? ?? 'unknown',
        ),
        confidence: (detection['confidence'] as num).toDouble(),
      );
    }).toList();

    return DetectionResult(
      frameId: data['frameId'] as String,
      detected: data['detected'] as int,
      compliant: data['compliant'] as int,
      nonCompliant: data['nonCompliant'] as int? ??
                   data['noncompliant'] as int? ?? 0,
      detections: detections,
    );
  }

  PPEType _parsePPEType(String type) {
    switch (type.toLowerCase()) {
      case 'hardhat':
        return PPEType.hardHat;
      case 'safetyglasses':
        return PPEType.safetyGlasses;
      case 'vest':
        return PPEType.vest;
      case 'gloves':
        return PPEType.gloves;
      case 'steeltoedboots':
        return PPEType.steelToedBoots;
      case 'earprotection':
        return PPEType.earProtection;
      default:
        return PPEType.hat;
    }
  }

  PPEStatus _parsePPEStatus(String status) {
    switch (status.toLowerCase()) {
      case 'compliant':
        return PPEStatus.compliant;
      case 'noncompliant':
      case 'missing':
        return PPEStatus.missing;
      case 'partial':
      case 'not_suitable':
      case 'nonsuitable':
        return PPEStatus.notSuitable;
      default:
        return PPEStatus.missing;
    }
  }

  ComplianceStatus _parseOverallStatus(String status) {
    switch (status.toLowerCase()) {
      case 'compliant':
        return ComplianceStatus.compliant;
      case 'partial':
        return ComplianceStatus.partial;
      case 'noncompliant':
        return ComplianceStatus.nonCompliant;
      default:
        return ComplianceStatus.compliant;
    }
  }

  Exception _handleDioError(dio.DioException error) {
    switch (error.type) {
      case dio.DioExceptionType.connectionTimeout:
      case dio.DioExceptionType.sendTimeout:
      case dio.DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Please check your network.');

      case dio.DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['detail'] ??
            error.response?.data?['message'] ??
            'Request failed';
        return Exception('Error $statusCode: $message');

      case dio.DioExceptionType.cancel:
        return Exception('Request was cancelled');

      case dio.DioExceptionType.connectionError:
        return Exception(
            'Cannot connect to server. Make sure the backend is running at ${ApiConstants.baseUrl}');

      case dio.DioExceptionType.unknown:
      default:
        return Exception('An error occurred: ${error.message}');
    }
  }
}
