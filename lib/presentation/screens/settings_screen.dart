import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../widgets/common/ambient_backdrop.dart';
import '../widgets/common/bottom_nav_bar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../routes/app_routes.dart';

/// Settings screen — modern profile + preference sections over the floating
/// liquid-glass nav bar, matching the rest of the redesigned app.
class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
      body: Stack(
        children: [
          const AmbientBackdrop(),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader()
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.2, end: 0, curve: Curves.easeOut),
                Expanded(
                  child: Obx(
                    () => SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                      child: Column(
                        children: [
                          _buildProfileCard()
                              .animate()
                              .fadeIn(delay: 100.ms, duration: 450.ms)
                              .slideY(begin: 0.15, end: 0, curve: Curves.easeOut),
                          const SizedBox(height: 24),
                          _buildSectionTitle('General Preferences'),
                          const SizedBox(height: 12),
                          _buildGeneralPreferences(),
                          const SizedBox(height: 24),
                          _buildSectionTitle('Safety & Alerts'),
                          const SizedBox(height: 12),
                          _buildSafetyAlerts(),
                          const SizedBox(height: 24),
                          _buildSectionTitle('Security'),
                          const SizedBox(height: 12),
                          _buildSecurity(),
                          const SizedBox(height: 24),
                          _buildLogoutButton(),
                          const SizedBox(height: 16),
                          _buildFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Brand header with title and overflow menu.
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 10),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.45),
                  blurRadius: 18,
                  spreadRadius: -2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.settings_outlined,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Account',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 2),
                Text('Settings',
                    style: AppTextStyles.headlineSmall.copyWith(fontSize: 22)),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
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
      ),
    );
  }

  /// Profile card with gradient avatar ring.
  Widget _buildProfileCard() {
    final settings = controller.userSettings.value;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF152444)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 26,
            spreadRadius: -6,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 78,
                height: 78,
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  gradient: AppColors.brandGradient,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.cardBackground,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.engineering,
                      size: 42, color: AppColors.accent),
                ),
              ),
              if (settings.isOnline)
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFF152444), width: 3),
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
                Text(settings.title,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.accent)),
                const SizedBox(height: 4),
                Text('ID: ${settings.employeeId}',
                    style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          GestureDetector(
            onTap: controller.openEditProfile,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: const Text('Edit', style: AppTextStyles.button),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: AppTextStyles.label
            .copyWith(color: AppColors.textPrimary, fontSize: 16),
      ),
    );
  }

  Widget _sectionCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildGeneralPreferences() {
    return _sectionCard([
      _buildSettingsItem(
        icon: Icons.language,
        title: 'App Language',
        value: controller.language.value == 'ar' ? 'العربية' : 'English',
        onTap: () {
          controller
              .setLanguage(controller.language.value == 'ar' ? 'en' : 'ar');
        },
      ),
      _buildDivider(),
      _buildSettingsItem(
        icon: Icons.palette_outlined,
        title: 'Appearance',
        value: 'System Dark',
        onTap: () {},
      ),
    ]);
  }

  Widget _buildSafetyAlerts() {
    return _sectionCard([
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
    ]);
  }

  Widget _buildSecurity() {
    return _sectionCard([
      _buildSettingsItem(
        icon: Icons.fingerprint_outlined,
        title: 'Biometric Auth',
        value:
            controller.userSettings.value.biometricAuth ? 'Enabled' : 'Disabled',
        onTap: controller.openBiometricSettings,
      ),
      _buildDivider(),
      _buildSettingsItem(
        icon: Icons.privacy_tip_outlined,
        title: 'Privacy Settings',
        value: '',
        onTap: controller.openPrivacySettings,
      ),
    ]);
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
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

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final color = value ? AppColors.success : AppColors.textDisabled;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Icon(icon, color: color),
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
            activeTrackColor: AppColors.success.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: AppColors.border,
      indent: 74,
      endIndent: 16,
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.logout,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error.withValues(alpha: 0.15),
          foregroundColor: AppColors.error,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
          ),
        ),
        child: controller.isLoading.value
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.error),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('Log Out',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error)),
                ],
              ),
      ),
    );
  }

  Widget _buildFooter() {
    return Text(
      'SAFEEYE V1.0.0 (STABLE)',
      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textDisabled),
    );
  }

  void _showAboutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('About SafeEye',
            style: AppTextStyles.headlineSmall),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SafeEye - Industrial Safety Monitoring App',
                style: AppTextStyles.bodyMedium),
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
