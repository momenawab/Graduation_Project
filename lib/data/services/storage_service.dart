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

  /// Clears all user-specific data (logout).
  Future<void> clearUserData() async {
    await prefs.remove(_userIdKey);
    await prefs.remove(_authTokenKey);
  }

  /// Clears all stored data.
  Future<void> clearAll() async {
    await prefs.clear();
  }
}
