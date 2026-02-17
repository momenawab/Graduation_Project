import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/user_settings.dart' as models;
import '../../routes/app_routes.dart';

/// Controller for managing app settings and user profile
class SettingsController extends GetxController {
  /// User settings observable
  final Rx<models.UserSettings> userSettings = Rx<models.UserSettings>(
    models.UserSettings(
      userId: 'user_123',
      fullName: 'Jane Doe',
      title: 'Senior Safety Inspector',
      employeeId: '78910-SF',
      avatarUrl: null,
      language: 'en_US',
      appearance: models.ThemeMode.dark,
      hazardAlerts: true,
      safeZoneMonitoring: true,
      biometricAuth: false,
      isOnline: true,
    ),
  );

  /// Hazard alerts toggle observable
  final RxBool hazardAlerts = true.obs;

  /// Safe zone monitoring toggle observable
  final RxBool safeZoneMonitoring = true.obs;

  /// Loading state for operations
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize toggles from user settings
    hazardAlerts.value = userSettings.value.hazardAlerts;
    safeZoneMonitoring.value = userSettings.value.safeZoneMonitoring;
  }

  /// Updates user profile information
  Future<void> updateProfile({
    String? fullName,
    String? title,
    String? avatarUrl,
  }) async {
    try {
      isLoading.value = true;

      // Update user settings with new values
      userSettings.value = userSettings.value.copyWith(
        fullName: fullName ?? userSettings.value.fullName,
        title: title ?? userSettings.value.title,
        avatarUrl: avatarUrl ?? userSettings.value.avatarUrl,
      );

      // TODO: Call API to update profile on server
      // await _settingsApi.updateProfile(userSettings.value);

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Opens edit profile dialog (stub for now)
  void openEditProfile() {
    // TODO: Implement edit profile dialog
    Get.dialog(
      AlertDialog(
        title: const Text('Edit Profile'),
        content: const Text(
          'Profile editing will be implemented in future update.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  /// Toggles hazard alerts setting
  void toggleHazardAlerts(bool value) {
    hazardAlerts.value = value;
    userSettings.value = userSettings.value.copyWith(hazardAlerts: value);

    // TODO: Persist to shared_preferences
    // TODO: Sync with server if online
  }

  /// Toggles safe zone monitoring setting
  void toggleSafeZoneMonitoring(bool value) {
    safeZoneMonitoring.value = value;
    userSettings.value = userSettings.value.copyWith(safeZoneMonitoring: value);

    // TODO: Persist to shared_preferences
    // TODO: Sync with server if online
  }

  /// Logs out the user and navigates to splash/login
  Future<void> logout() async {
    try {
      isLoading.value = true;

      // TODO: Clear stored credentials
      // await _authService.logout();

      // TODO: Clear local storage
      // await _storage.clear();

      // Navigate to splash screen
      Get.offAllNamed(AppRoutes.SPLASH);

      Get.snackbar(
        'Logged Out',
        'You have been logged out successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Opens biometric authentication settings
  void openBiometricSettings() {
    // TODO: Implement biometric settings
    Get.dialog(
      AlertDialog(
        title: const Text('Biometric Authentication'),
        content: const Text(
          'Biometric authentication settings will be implemented in future update.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  /// Opens privacy settings
  void openPrivacySettings() {
    // TODO: Implement privacy settings
    Get.dialog(
      AlertDialog(
        title: const Text('Privacy Settings'),
        content: const Text(
          'Privacy settings will be implemented in future update.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  void onClose() {
    super.onClose();
  }
}
