import '../../../core/constants/api_constants.dart';
import '../../models/user_settings.dart';
import 'api_client.dart';

/// Settings API — wired to the SafeEye Django auth endpoints
/// (`/auth/settings/`, `/auth/profile/`, `/auth/logout/`).
class SettingsApi {
  /// The API client instance
  final ApiClient apiClient;

  /// Creates a new SettingsApi instance.
  SettingsApi({required this.apiClient});

  ThemeMode _themeFromString(String? t) {
    switch (t) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  UserSettings _build(Map<String, dynamic> settings, Map<String, dynamic> profile) {
    final account = (settings['account'] as Map<String, dynamic>?) ?? {};
    final notifications = (settings['notifications'] as Map<String, dynamic>?) ?? {};
    final fullName = (account['name'] as String?) ??
        '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}'.trim();
    return UserSettings(
      userId: (profile['id']?.toString()) ?? '',
      fullName: fullName.isEmpty ? (profile['username'] as String? ?? '') : fullName,
      title: (profile['role'] as String?) ?? '',
      employeeId: (profile['id']?.toString()) ?? '',
      avatarUrl: null,
      language: (settings['language'] as String?) ?? 'en_US',
      appearance: _themeFromString(settings['theme'] as String?),
      hazardAlerts: (notifications['in_app'] as bool?) ?? true,
      safeZoneMonitoring: true,
      biometricAuth: false,
      isOnline: true,
    );
  }

  /// Gets user settings (merges /auth/settings/ + /auth/profile/).
  Future<UserSettings> getSettings() async {
    final settingsRes = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.settings.fullPath,
    );
    final profileRes = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.profile.fullPath,
    );
    return _build(settingsRes.data ?? {}, profileRes.data ?? {});
  }

  /// Updates user settings.
  /// PUT /api/auth/settings/
  Future<UserSettings> updateSettings(UserSettings settings) async {
    await apiClient.put<Map<String, dynamic>>(
      ApiConstants.settings.fullPath,
      data: {
        'language': settings.language,
        'theme': _themeToString(settings.appearance),
        'notifications': {
          'in_app': settings.hazardAlerts,
        },
      },
    );
    return settings;
  }

  /// Gets the user profile mapped to [UserSettings].
  Future<UserSettings> getProfile() async {
    final profileRes = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.profile.fullPath,
    );
    return _build({}, profileRes.data ?? {});
  }

  /// Updates the user profile.
  /// PUT /api/auth/profile/
  Future<UserSettings> updateProfile(UserSettings profile) async {
    final parts = profile.fullName.trim().split(' ');
    await apiClient.put<Map<String, dynamic>>(
      ApiConstants.profile.fullPath,
      data: {
        'first_name': parts.isNotEmpty ? parts.first : '',
        'last_name': parts.length > 1 ? parts.sublist(1).join(' ') : '',
      },
    );
    return profile;
  }

  /// Changes the user's password.
  /// POST /api/auth/change-password/
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await apiClient.post<Map<String, dynamic>>(
      ApiConstants.changePassword.fullPath,
      data: {
        'old_password': oldPassword,
        'new_password': newPassword,
        'new_password_confirm': newPassword,
      },
    );
  }

  /// Uploads a user avatar. Not supported by the current backend.
  Future<String> uploadAvatar(String filePath) async {
    throw Exception('Avatar upload is not supported by the backend yet.');
  }

  /// Gets available languages.
  Future<List<Map<String, dynamic>>> getLanguages() async {
    return [
      {'code': 'en_US', 'name': 'English (US)'},
      {'code': 'ar', 'name': 'العربية'},
      {'code': 'es_ES', 'name': 'Español'},
      {'code': 'fr_FR', 'name': 'Français'},
    ];
  }

  /// Logs out the user.
  /// POST /api/auth/logout/
  Future<void> logout() async {
    await apiClient.post<Map<String, dynamic>>(ApiConstants.logout.fullPath);
  }
}
