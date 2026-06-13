/// API configuration constants for SafeSight backend integration.
class ApiConstants {
  /// Base URL for the Django backend API
  /// For local development, use localhost or your emulator's IP
  /// For Android emulator: use '10.0.2.2' instead of 'localhost'
  /// For iOS simulator: use 'localhost' or '127.0.0.1'
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
  //  defaultValue: 'http://138.199.148.126',
  defaultValue: 'http://172.20.10.9:8000',
  );

  /// WebSocket URL for real-time detection
  static String get wsUrl => baseUrl.replaceFirst('http', 'ws');

  /// API Endpoints
  static const String apiPath = '/api';

  // Auth endpoints
  static const String login = '/auth/login/';
  static const String register = '/auth/register/';
  static const String logout = '/auth/logout/';
  static const String profile = '/auth/profile/';
  static const String createWorkerAccount = '/auth/workers/create-account/';

  // Detection endpoints
  static const String detectionUpload = '/detection/upload/';
  static const String detectionRecords = '/detection/records/';
  static const String detectionViolations = '/detection/violations/';
  static const String detectionHealth = '/detection/health/';
  static const String detectionDashboard = '/detection/dashboard-stats/';
  static const String detectionSessions = '/detection/sessions/';

  // WebSocket endpoint
  static const String wsDetection = '/ws/detect/';
  static const String wsNotifications = '/ws/notifications/';

  // Worker endpoints
  static const String workers = '/workers/';
  static const String workerAddWithPhoto = '/workers/add-with-photo/';
  static const String workerById = '/workers/id/';
  static const String workerViolations = '/workers/violations/';

  // Alert endpoints
  static const String alertConfig = '/alerts/config/';
  static const String alertHistory = '/alerts/history/';
  static const String alertTest = '/alerts/test/';

  // Report endpoints
  static const String reportSummary = '/reports/summary/';
  static const String reportViolations = '/reports/violations/';
  static const String reportCompliance = '/reports/compliance/';
  static const String reportExport = '/reports/export/';

  /// Timeout duration for API requests
  static const Duration requestTimeout = Duration(seconds: 30);

  /// WebSocket connection timeout
  static const Duration wsTimeout = Duration(seconds: 10);

  /// Image upload max size (10MB)
  static const int maxImageSize = 10 * 1024 * 1024;
}

/// Full URL builder helper
extension ApiConstantsExtension on String {
  String get fullPath => '${ApiConstants.apiPath}${this}';
}
