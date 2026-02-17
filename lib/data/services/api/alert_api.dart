import '../../models/alert_config.dart';
import 'api_client.dart';

/// Alert API stub with methods for alert configuration and management.
///
/// This is a stub implementation that returns mock data.
/// In production, this would make actual HTTP requests to the backend API.
class AlertApi {
  /// The API client instance
  final ApiClient apiClient;

  /// Creates a new AlertApi instance.
  AlertApi({required this.apiClient});

  /// Gets all alert configurations.
  Future<List<AlertConfig>> getConfig() async {
    // TODO: Replace with actual API call
    // final response = await apiClient.get<List<dynamic>>('/alerts/config');
    // return response.data.map((json) => AlertConfig.fromJson(json)).toList();

    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 400));
    return [];
  }

  /// Updates an alert configuration.
  Future<AlertConfig> updateConfig(AlertConfig config) async {
    // TODO: Replace with actual API call
    // final response = await apiClient.put<Map<String, dynamic>>(
    //   '/alerts/config/${config.alertType.name}',
    //   data: config.toJson(),
    // );
    // return AlertConfig.fromJson(response.data);

    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 300));
    return config;
  }

  /// Gets alert history.
  Future<List<Map<String, dynamic>>> getHistory() async {
    // TODO: Replace with actual API call
    // final response = await apiClient.get<List<dynamic>>('/alerts/history');
    // return response.data.cast<Map<String, dynamic>>();

    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }

  /// Marks an alert as read.
  Future<void> markAsRead(String alertId) async {
    // TODO: Replace with actual API call
    // await apiClient.put<void>('/alerts/$alertId/read');

    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 200));
  }

  /// Marks all alerts as read.
  Future<void> markAllAsRead() async {
    // TODO: Replace with actual API call
    // await apiClient.put<void>('/alerts/read-all');

    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Deletes an alert.
  Future<void> deleteAlert(String alertId) async {
    // TODO: Replace with actual API call
    // await apiClient.delete<void>('/alerts/$alertId');

    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 200));
  }

  /// Tests an alert configuration.
  Future<Map<String, dynamic>> testAlert(AlertConfig config) async {
    // TODO: Replace with actual API call
    // final response = await apiClient.post<Map<String, dynamic>>(
    //   '/alerts/test',
    //   data: config.toJson(),
    // );
    // return response.data;

    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 500));
    return {'success': true, 'message': 'Alert test successful'};
  }
}
