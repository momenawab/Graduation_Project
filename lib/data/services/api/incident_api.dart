import 'dart:io';
import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import 'api_client.dart';

/// F15 — manual incident / near-miss reporting.
class IncidentApi {
  final ApiClient apiClient;
  IncidentApi({required this.apiClient});

  /// GET /api/incidents/
  Future<List<Map<String, dynamic>>> getIncidents() async {
    final res = await apiClient.dio.get(ApiConstants.incidents.fullPath);
    final body = res.data;
    final List list = body is List
        ? body
        : (body is Map && body['results'] is List)
            ? body['results'] as List
            : const [];
    return list.cast<Map<String, dynamic>>();
  }

  /// POST /api/incidents/  (multipart if a photo is attached).
  Future<Map<String, dynamic>> createIncident({
    required String title,
    String severity = 'medium',
    String? location,
    String? description,
    File? photo,
  }) async {
    dynamic data;
    if (photo != null) {
      data = FormData.fromMap({
        'title': title,
        'severity': severity,
        if (location != null) 'location': location,
        if (description != null) 'description': description,
        'photo': await MultipartFile.fromFile(photo.path,
            filename: photo.path.split('/').last),
      });
    } else {
      data = {
        'title': title,
        'severity': severity,
        if (location != null) 'location': location,
        if (description != null) 'description': description,
      };
    }
    final res = await apiClient.dio.post(ApiConstants.incidents.fullPath, data: data);
    return (res.data as Map).cast<String, dynamic>();
  }
}
