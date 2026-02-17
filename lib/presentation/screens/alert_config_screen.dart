import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/alert_config_controller.dart';
import '../../data/models/alert_config.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart' as styles;

/// Alert configuration screen with toggle switches and delivery mode selection.
@immutable
class AlertConfigScreen extends StatelessWidget {
  const AlertConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AlertConfigController controller = Get.put(AlertConfigController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top app bar with back button, title, and menu icon
            _buildTopAppBar(),

            // Content area
            Expanded(child: _buildContent(controller)),

            // Bottom navigation
            const _AlertConfigBottomNav(),
          ],
        ),
      ),
    );
  }

  /// Builds top app bar with back button, title, and menu icon.
  Widget _buildTopAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button and title
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'ALERT CONFIG',
                style: styles.AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          // Menu icon button
          GestureDetector(
            onTap: () {
              // TODO: Open menu options
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.menu,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds main content area.
  Widget _buildContent(AlertConfigController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Safety Critical Systems section
          _buildSafetyCriticalSystemsSection(controller),

          const SizedBox(height: 24),

          // Intelligence Feed section
          _buildIntelligenceFeedSection(controller),

          const SizedBox(height: 24),

          // Commit Changes button
          _buildCommitButton(controller),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Builds Safety Critical Systems section.
  Widget _buildSafetyCriticalSystemsSection(AlertConfigController controller) {
    return Obx(() {
      final safetySystems = controller.safetyCriticalSystems;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            'Safety Critical Systems',
            style: styles.AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          // Alert toggles
          ...safetySystems.map((config) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _AlertToggleCard(
                icon: controller.getAlertTypeIcon(config.alertType),
                title: controller.getAlertTypeName(config.alertType),
                enabled: config.enabled,
                enabledColor: controller.getEnabledColor(config.enabled),
                onTap: () => controller.toggleAlert(config.alertType),
                showDeliveryMode: config.alertType == AlertType.ppeCompliance,
                deliveryMode: config.deliveryMode,
                onDeliveryModeChanged:
                    config.alertType == AlertType.ppeCompliance
                    ? (mode) =>
                          controller.setDeliveryMode(config.alertType, mode)
                    : null,
                getDeliveryModeColor: (mode) =>
                    controller.getDeliveryModeColor(mode, config.deliveryMode),
              ),
            );
          }).toList(),
        ],
      );
    });
  }

  /// Builds Intelligence Feed section.
  Widget _buildIntelligenceFeedSection(AlertConfigController controller) {
    return Obx(() {
      final intelligenceFeed = controller.intelligenceFeed;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            'Intelligence Feed',
            style: styles.AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          // Alert toggles
          ...intelligenceFeed.map((config) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _AlertToggleCard(
                icon: controller.getAlertTypeIcon(config.alertType),
                title: controller.getAlertTypeName(config.alertType),
                enabled: config.enabled,
                enabledColor: controller.getEnabledColor(config.enabled),
                onTap: () => controller.toggleAlert(config.alertType),
                getDeliveryModeColor: (mode) =>
                    controller.getDeliveryModeColor(mode, config.deliveryMode),
              ),
            );
          }).toList(),
        ],
      );
    });
  }

  /// Builds commit changes button with gradient background.
  Widget _buildCommitButton(AlertConfigController controller) {
    return Obx(() {
      return GestureDetector(
        onTap: controller.isLoading.value ? null : controller.commitChanges,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00BCD4), Color(0xFF9C27B0)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'COMMIT CHANGES',
                  textAlign: TextAlign.center,
                  style: styles.AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
        ),
      );
    });
  }
}

/// Alert toggle card widget with icon, title, and toggle switch.
@immutable
class _AlertToggleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool enabled;
  final Color enabledColor;
  final VoidCallback onTap;
  final bool showDeliveryMode;
  final DeliveryMode deliveryMode;
  final ValueChanged<DeliveryMode>? onDeliveryModeChanged;
  final Color Function(DeliveryMode) getDeliveryModeColor;

  const _AlertToggleCard({
    required this.icon,
    required this.title,
    required this.enabled,
    required this.enabledColor,
    required this.onTap,
    this.showDeliveryMode = false,
    this.deliveryMode = DeliveryMode.dual,
    this.onDeliveryModeChanged,
    required this.getDeliveryModeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Main row with icon, title, and toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon and title
              Row(
                children: [
                  Icon(icon, color: enabledColor, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: styles.AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),

              // Toggle switch
              GestureDetector(
                onTap: onTap,
                child: Container(
                  width: 52,
                  height: 28,
                  decoration: BoxDecoration(
                    color: enabled
                        ? const Color(0xFF00BCD4)
                        : const Color(0xFF9E9E9E),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Align(
                      alignment: enabled
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Delivery mode tabs (only for PPE Compliance)
          if (showDeliveryMode && onDeliveryModeChanged != null) ...[
            const SizedBox(height: 12),
            _DeliveryModeTabs(
              selectedMode: deliveryMode,
              onModeChanged: onDeliveryModeChanged,
              getModeColor: getDeliveryModeColor,
            ),
          ],
        ],
      ),
    );
  }
}

/// Delivery mode tabs widget for selecting Audio, Haptic, or Dual mode.
@immutable
class _DeliveryModeTabs extends StatelessWidget {
  final DeliveryMode selectedMode;
  final ValueChanged<DeliveryMode>? onModeChanged;
  final Color Function(DeliveryMode) getModeColor;

  const _DeliveryModeTabs({
    required this.selectedMode,
    required this.onModeChanged,
    required this.getModeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DeliveryModeTab(
            label: 'Audio',
            mode: DeliveryMode.audio,
            selectedMode: selectedMode,
            onModeChanged: onModeChanged,
            getModeColor: getModeColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _DeliveryModeTab(
            label: 'Haptic',
            mode: DeliveryMode.haptic,
            selectedMode: selectedMode,
            onModeChanged: onModeChanged,
            getModeColor: getModeColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _DeliveryModeTab(
            label: 'Dual',
            mode: DeliveryMode.dual,
            selectedMode: selectedMode,
            onModeChanged: onModeChanged,
            getModeColor: getModeColor,
          ),
        ),
      ],
    );
  }
}

/// Single delivery mode tab.
@immutable
class _DeliveryModeTab extends StatelessWidget {
  final String label;
  final DeliveryMode mode;
  final DeliveryMode selectedMode;
  final ValueChanged<DeliveryMode>? onModeChanged;
  final Color Function(DeliveryMode) getModeColor;

  const _DeliveryModeTab({
    required this.label,
    required this.mode,
    required this.selectedMode,
    required this.onModeChanged,
    required this.getModeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = mode == selectedMode;
    final color = getModeColor(mode);

    return GestureDetector(
      onTap: onModeChanged != null ? () => onModeChanged!(mode) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: styles.AppTextStyles.bodySmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// Alert config bottom navigation widget.
@immutable
class _AlertConfigBottomNav extends StatelessWidget {
  const _AlertConfigBottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(
          top: BorderSide(color: AppColors.textSecondary, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.grid_view,
            label: 'Grid',
            isActive: false,
            onTap: () => Get.toNamed('/'),
          ),
          _NavItem(
            icon: Icons.remove_red_eye,
            label: 'Alerts',
            isActive: true,
            onTap: () {},
          ),
          _NavItem(
            icon: Icons.bar_chart,
            label: 'Chart',
            isActive: false,
            onTap: () => Get.toNamed('/reports'),
          ),
          _NavItem(
            icon: Icons.person,
            label: 'User',
            isActive: false,
            onTap: () => Get.toNamed('/settings'),
          ),
        ],
      ),
    );
  }
}

/// Navigation item widget for bottom nav.
@immutable
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF00BCD4) : AppColors.textSecondary,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: styles.AppTextStyles.bodySmall.copyWith(
              color: isActive
                  ? const Color(0xFF00BCD4)
                  : AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
