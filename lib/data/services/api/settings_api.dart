import '../../models/user_settings.dart';
import 'api_client.dart';

/// Settings API stub with methods for user settings and profile management.
///
/// This is a stub implementation that returns mock data.
/// In production, this would make actual HTTP requests to the backend API.
class SettingsApi {
  /// The API client instance
  final ApiClient apiClient;

  /// Creates a new SettingsApi instance.
  SettingsApi({required this.apiClient});

  /// Gets user settings.
  Future<UserSettings> getSettings() async {
    // TODO: Replace with actual API call
    // final response = await apiClient.get<Map<String, dynamic>>('/settings');
    // return UserSettings.fromJson(response.data);

    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 400));
    throw Exception('Settings not available');
  }

  /// Updates user settings.
  Future<UserSettings> updateSettings(UserSettings settings) async {
    // TODO: Replace with actual API call
    // final response = await apiClient.put<Map<String, dynamic>>(
    //   '/settings',
    //   data: settings.toJson(),
    // );
    // return UserSettings.fromJson(response.data);

    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 300));
    return settings;
  }

  /// Gets user profile.
  Future<UserSettings> getProfile() async {
    // TODO: Replace with actual API call
    // final response = await apiClient.get<Map<String, dynamic>>('/profile');
    // return UserSettings.fromJson(response.data);

    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 300));
    throw Exception('Profile not found');
  }

  /// Updates user profile.
  Future<UserSettings> updateProfile(UserSettings profile) async {
    // TODO: Replace with actual API call
    // final response = await apiClient.put<Map<String, dynamic>>(
    //   '/profile',
    //   data: profile.toJson(),
    // );
    // return UserSettings.fromJson(response.data);

    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 400));
    return profile;
  }

  /// Uploads a user avatar.
  Future<String> uploadAvatar(String filePath) async {
    // TODO: Replace with actual API call
    // final formData = FormData.fromMap({
    //   'avatar': await MultipartFile.fromFile(filePath),
    // });
    // final response = await apiClient.post<Map<String, dynamic>>(
    //   '/profile/avatar',
    //   data: formData,
    // );
    // return response.data['avatarUrl'] as String;

    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 1500));
    throw Exception('Avatar upload not available');
  }

  /// Gets available languages.
  Future<List<Map<String, dynamic>>> getLanguages() async {
    // TODO: Replace with actual API call
    // final response = await apiClient.get<List<dynamic>>('/settings/languages');
    // return response.data.cast<Map<String, dynamic>>();

    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      {'code': 'en_US', 'name': 'English (US)'},
      {'code': 'es_ES', 'name': 'Español'},
      {'code': 'fr_FR', 'name': 'Français'},
      {'code': 'de_DE', 'name': 'Deutsch'},
      {'code': 'zh_CN', 'name': '中文'},
    ];
  }

  /// Logs out the user.
  Future<void> logout() async {
    // TODO: Replace with actual API call
    // await apiClient.post<void>('/auth/logout');

    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
