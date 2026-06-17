/// API configuration constants for SafeSight backend integration.
class ApiConstants {
  /// Base URL for the Django backend API.
  ///
  /// Override per build with --dart-define, e.g. for the AWS deployment:
  ///   flutter run --dart-define=API_BASE_URL=https://your-aws-host
  ///   flutter build apk --dart-define=API_BASE_URL=https://your-aws-host
  ///
  /// Local development defaults:
  ///   Android emulator: http://10.0.2.2:8000
  ///   iOS simulator:    http://127.0.0.1:8000
  /// wsUrl is derived automatically (https -> wss).
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://16.171.170.25:80/',
  );

  /// WebSocket URL for real-time detection.
  /// Strips any trailing slash so `${wsUrl}${wsDetection}` doesn't double up.
  static String get wsUrl =>
      baseUrl.replaceFirst('http', 'ws').replaceFirst(RegExp(r'/+$'), '');

  /// API Endpoints
  static const String apiPath = '/api';

  // Auth endpoints
  static const String login = '/auth/login/';
  static const String register = '/auth/register/';
  static const String logout = '/auth/logout/';
  static const String profile = '/auth/profile/';
  static const String changePassword = '/auth/change-password/';
  static const String settings = '/auth/settings/';
  static const String notificationPreferences = '/auth/notification-preferences/';
  static const String createWorkerAccount = '/auth/workers/create-account/';

  // Cameras
  static const String cameras = '/cameras/';

  // Content
  static const String howTo = '/content/how-to/';

  // Incidents (F15)
  static const String incidents = '/incidents/';

  // Alerts (extra)
  static const String alertStats = '/alerts/stats/';
  static const String alertRecipients = '/alerts/recipients/';
  static const String alertConfigCreate = '/alerts/config/create/';

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
