import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../widgets/common/bottom_nav_bar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../routes/app_routes.dart';

/// Settings screen for managing app settings and user profile
class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Obx(() => _buildBody()),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// Builds the app bar with back button and three-dot menu
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.cardBackground,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => Get.back(),
      ),
      title: const Text('Settings', style: AppTextStyles.headlineSmall),
      centerTitle: true,
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
          color: AppColors.cardBackground,
          onSelected: (value) {
            switch (value) {
              case 'help':
                Get.toNamed(AppRoutes.INSTRUCTIONS);
                break;
              case 'about':
                _showAboutDialog();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'help',
              child: Row(
                children: [
                  Icon(Icons.help_outline, color: AppColors.textSecondary),
                  SizedBox(width: 12),
                  Text('Help', style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'about',
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.textSecondary),
                  SizedBox(width: 12),
                  Text('About', style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the main body content
  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildProfileCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('General Preferences'),
          _buildGeneralPreferences(),
          const SizedBox(height: 24),
          _buildSectionTitle('Safety & Alerts'),
          _buildSafetyAlerts(),
          const SizedBox(height: 24),
          _buildSectionTitle('Security'),
          _buildSecurity(),
          const SizedBox(height: 24),
          _buildLogoutButton(),
          const SizedBox(height: 16),
          _buildFooter(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Builds the profile card
  Widget _buildProfileCard() {
    final settings = controller.userSettings.value;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.engineering,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              if (settings.isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.cardBackground,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(settings.fullName, style: AppTextStyles.headlineSmall),
                const SizedBox(height: 4),
                Text(settings.title, style: AppTextStyles.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  'ID: ${settings.employeeId}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: controller.openEditProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Edit', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  /// Builds a section title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: AppTextStyles.label.copyWith(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
      ),
    );
  }

  /// Builds the General Preferences section
  Widget _buildGeneralPreferences() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSettingsItem(
            icon: Icons.language,
            title: 'App Language',
            value: 'English (US)',
            onTap: () {
              // TODO: Implement language selection
            },
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.palette_outlined,
            title: 'Appearance',
            value: 'System Dark',
            onTap: () {
              // TODO: Implement theme selection
            },
          ),
        ],
      ),
    );
  }

  /// Builds the Safety & Alerts section
  Widget _buildSafetyAlerts() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildToggleItem(
            icon: Icons.warning_amber_outlined,
            title: 'Hazard Alerts',
            subtitle: 'Receive alerts for safety hazards',
            value: controller.hazardAlerts.value,
            onChanged: controller.toggleHazardAlerts,
          ),
          _buildDivider(),
          _buildToggleItem(
            icon: Icons.location_on_outlined,
            title: 'Safe Zone Monitoring',
            subtitle: 'Monitor safe zone compliance',
            value: controller.safeZoneMonitoring.value,
            onChanged: controller.toggleSafeZoneMonitoring,
          ),
        ],
      ),
    );
  }

  /// Builds the Security section
  Widget _buildSecurity() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSettingsItem(
            icon: Icons.fingerprint_outlined,
            title: 'Biometric Auth',
            value: controller.userSettings.value.biometricAuth
                ? 'Enabled'
                : 'Disabled',
            onTap: controller.openBiometricSettings,
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Settings',
            value: '',
            onTap: controller.openPrivacySettings,
          ),
        ],
      ),
    );
  }

  /// Builds a settings item with icon, title, value, and arrow
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyLarge),
                  if (value.isNotEmpty)
                    Text(value, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  /// Builds a toggle item with icon, title, subtitle, and switch
  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: value
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.textDisabled.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: value ? AppColors.success : AppColors.textDisabled,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyLarge),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.success,
            activeTrackColor: AppColors.success.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  /// Builds a divider between list items
  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: AppColors.textDisabled.withOpacity(0.2),
      indent: 72,
    );
  }

  /// Builds the logout button
  Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.logout,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          disabledBackgroundColor: AppColors.error.withOpacity(0.5),
        ),
        child: controller.isLoading.value
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Log Out', style: AppTextStyles.button),
                ],
              ),
      ),
    );
  }

  /// Builds the footer with version info
  Widget _buildFooter() {
    return Text(
      'SAFESIGHT V1.0.0 (STABLE)',
      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textDisabled),
    );
  }

  /// Builds the bottom navigation bar
  Widget _buildBottomNavigationBar() {
    return BottomNavBar(
      currentIndex: 3, // Settings is active
      backgroundColor: AppColors.cardBackground,
    );
  }

  /// Shows the about dialog
  void _showAboutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'About SafeSight',
          style: AppTextStyles.headlineSmall,
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SafeSight - Industrial Safety Monitoring App',
              style: AppTextStyles.bodyMedium,
            ),
            SizedBox(height: 8),
            Text('Version: 1.0.0 (STABLE)', style: AppTextStyles.bodySmall),
            SizedBox(height: 16),
            Text(
              'AI-powered safety compliance monitoring for industrial environments.',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }
}
