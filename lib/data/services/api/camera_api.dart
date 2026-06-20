import '../../../core/constants/api_constants.dart';
import 'api_client.dart';

/// Camera API — wired to the SafeEye Django cameras endpoints.
///
/// Cameras are metadata entities (name, IP, location, status). Live frame
/// analysis is handled separately by the `/ws/detect/` WebSocket.
class CameraApi {
  /// The API client instance
  final ApiClient apiClient;

  /// Creates a new CameraApi instance.
  CameraApi({required this.apiClient});

  /// Lists all cameras.
  /// GET /api/cameras/
  Future<List<Map<String, dynamic>>> getCameras() async {
    final response = await apiClient.get<dynamic>(ApiConstants.cameras.fullPath);
    final body = response.data;
    final List list = body is List
        ? body
        : (body is Map && body['results'] is List)
            ? body['results'] as List
            : const [];
    return list.cast<Map<String, dynamic>>();
  }

  /// Adds a camera.
  /// POST /api/cameras/
  Future<Map<String, dynamic>> addCamera({
    required String name,
    String? ipAddress,
    String? location,
    List<String>? requiredPpe,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.cameras.fullPath,
      data: {
        'name': name,
        if (ipAddress != null) 'ip_address': ipAddress,
        if (location != null) 'location': location,
        // Per-camera PPE policy the AI enforces for this camera/zone.
        if (requiredPpe != null) 'required_ppe': requiredPpe,
      },
    );
    return response.data ?? <String, dynamic>{};
  }

  /// Updates a camera.
  /// PUT /api/cameras/{id}/
  Future<Map<String, dynamic>> updateCamera(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await apiClient.put<Map<String, dynamic>>(
      '${ApiConstants.cameras.fullPath}$id/',
      data: data,
    );
    return response.data ?? <String, dynamic>{};
  }

  /// Deletes a camera.
  /// DELETE /api/cameras/{id}/
  Future<void> deleteCamera(int id) async {
    await apiClient.delete<void>('${ApiConstants.cameras.fullPath}$id/');
  }
}
