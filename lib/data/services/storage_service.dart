import 'package:shared_preferences/shared_preferences.dart';
import 'package:meta/meta.dart';

/// Local storage service for app settings and preferences.
///
/// Uses shared_preferences for persistent key-value storage.
@immutable
class StorageService {
  /// Singleton instance
  static StorageService? _instance;

  /// SharedPreferences instance
  final SharedPreferences prefs;

  /// Private constructor
  StorageService._({required this.prefs});

  /// Gets the singleton instance of StorageService.
  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      final prefs = await SharedPreferences.getInstance();
      _instance = StorageService._(prefs: prefs);
    }
    return _instance!;
  }

  // Language Settings
  static const String _userLanguageKey = 'user_language';
  static const String _defaultLanguage = 'en_US';

  /// Gets the user's language preference.
  String get userLanguage =>
      prefs.getString(_userLanguageKey) ?? _defaultLanguage;

  /// Sets the user's language preference.
  Future<bool> setUserLanguage(String language) async {
    return await prefs.setString(_userLanguageKey, language);
  }

  // Theme Settings
  static const String _appThemeKey = 'app_theme';
  static const String _defaultTheme = 'dark';

  /// Gets the app theme preference.
  String get appTheme => prefs.getString(_appThemeKey) ?? _defaultTheme;

  /// Sets the app theme preference.
  Future<bool> setAppTheme(String theme) async {
    return await prefs.setString(_appThemeKey, theme);
  }

  // Safety & Alerts Settings
  static const String _hazardAlertsKey = 'hazard_alerts';
  static const bool _defaultHazardAlerts = true;

  /// Gets the hazard alerts toggle state.
  bool get hazardAlerts =>
      prefs.getBool(_hazardAlertsKey) ?? _defaultHazardAlerts;

  /// Sets the hazard alerts toggle state.
  Future<bool> setHazardAlerts(bool enabled) async {
    return await prefs.setBool(_hazardAlertsKey, enabled);
  }

  // Safe Zone Monitoring Settings
  static const String _safeZoneMonitoringKey = 'safe_zone_monitoring';
  static const bool _defaultSafeZoneMonitoring = true;

  /// Gets the safe zone monitoring toggle state.
  bool get safeZoneMonitoring =>
      prefs.getBool(_safeZoneMonitoringKey) ?? _defaultSafeZoneMonitoring;

  /// Sets the safe zone monitoring toggle state.
  Future<bool> setSafeZoneMonitoring(bool enabled) async {
    return await prefs.setBool(_safeZoneMonitoringKey, enabled);
  }

  // Biometric Auth Settings
  static const String _biometricAuthKey = 'biometric_auth';
  static const bool _defaultBiometricAuth = false;

  /// Gets the biometric auth toggle state.
  bool get biometricAuth =>
      prefs.getBool(_biometricAuthKey) ?? _defaultBiometricAuth;

  /// Sets the biometric auth toggle state.
  Future<bool> setBiometricAuth(bool enabled) async {
    return await prefs.setBool(_biometricAuthKey, enabled);
  }

  // User Authentication
  static const String _userIdKey = 'user_id';
  static const String _authTokenKey = 'auth_token';
  static const String _userRoleKey = 'user_role';
  static const String _usernameKey = 'username';
  static const String _workerIdKey = 'worker_id';
  static const String _workerNameKey = 'worker_name';

  /// Gets the current user ID.
  String? get userId => prefs.getString(_userIdKey);

  /// Sets the current user ID.
  Future<bool> setUserId(String? userId) async {
    if (userId == null) {
      return await prefs.remove(_userIdKey);
    }
    return await prefs.setString(_userIdKey, userId!);
  }

  /// Gets the authentication token.
  String? get authToken => prefs.getString(_authTokenKey);

  /// Sets the authentication token.
  Future<bool> setAuthToken(String? token) async {
    if (token == null) {
      return await prefs.remove(_authTokenKey);
    }
    return await prefs.setString(_authTokenKey, token!);
  }

  /// Gets the user role.
  String? get userRole => prefs.getString(_userRoleKey);

  /// Sets the user role.
  Future<bool> setUserRole(String? role) async {
    if (role == null) {
      return await prefs.remove(_userRoleKey);
    }
    return await prefs.setString(_userRoleKey, role);
  }

  /// Gets the username.
  String? get username => prefs.getString(_usernameKey);

  /// Sets the username.
  Future<bool> setUsername(String? username) async {
    if (username == null) {
      return await prefs.remove(_usernameKey);
    }
    return await prefs.setString(_usernameKey, username);
  }

  /// Gets the worker ID (for worker role).
  String? get workerId => prefs.getString(_workerIdKey);

  /// Sets the worker ID.
  Future<bool> setWorkerId(String? workerId) async {
    if (workerId == null) {
      return await prefs.remove(_workerIdKey);
    }
    return await prefs.setString(_workerIdKey, workerId);
  }

  /// Gets the worker name (for worker role).
  String? get workerName => prefs.getString(_workerNameKey);

  /// Sets the worker name.
  Future<bool> setWorkerName(String? workerName) async {
    if (workerName == null) {
      return await prefs.remove(_workerNameKey);
    }
    return await prefs.setString(_workerNameKey, workerName);
  }

  /// Checks if user is logged in.
  bool get isLoggedIn => userId != null && authToken != null;

  /// Checks if current user is a worker.
  bool get isWorker => userRole == 'worker';

  /// Checks if current user is an admin.
  bool get isAdmin => userRole == 'admin' || userRole == 'supervisor';

  /// Clears all user-specific data (logout).
  Future<void> clearUserData() async {
    await prefs.remove(_userIdKey);
    await prefs.remove(_authTokenKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_workerIdKey);
    await prefs.remove(_workerNameKey);
  }

  /// Clears all stored data.
  Future<void> clearAll() async {
    await prefs.clear();
  }
}
