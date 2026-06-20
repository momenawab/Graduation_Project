import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../controllers/alert_config_controller.dart';
import '../widgets/common/ambient_backdrop.dart';
import '../../data/models/alert_config.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart' as styles;

/// Thresholds / Alert configuration screen — toggle which safety alerts fire,
/// pick their delivery mode, and commit changes. Styled to match the redesign.
@immutable
class AlertConfigScreen extends StatelessWidget {
  const AlertConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AlertConfigController controller = Get.put(AlertConfigController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const AmbientBackdrop(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(controller)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.2, end: 0, curve: Curves.easeOut),
                Expanded(child: _buildContent(controller)),
                _buildCommitButton(controller),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Brand header with back button and title.
  Widget _buildHeader(AlertConfigController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 12),
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
            child: const Icon(Icons.tune_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Configuration',
                    style: styles.AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 2),
                Text('Thresholds',
                    style: styles.AppTextStyles.headlineSmall.copyWith(fontSize: 22)),
              ],
            ),
          ),
          GestureDetector(
            onTap: controller.resetToDefaults,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.restart_alt,
                  color: AppColors.textSecondary, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AlertConfigController controller) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            controller,
            title: 'Safety Critical Systems',
            subtitle: 'High-priority alerts, delivered immediately',
            configs: () => controller.safetyCriticalSystems,
          ).animate().fadeIn(delay: 100.ms, duration: 420.ms),
          const SizedBox(height: 24),
          _buildSection(
            controller,
            title: 'Intelligence Feed',
            subtitle: 'Informational updates and metrics',
            configs: () => controller.intelligenceFeed,
          ).animate().fadeIn(delay: 200.ms, duration: 420.ms),
        ],
      ),
    );
  }

  Widget _buildSection(
    AlertConfigController controller, {
    required String title,
    required String subtitle,
    required List<AlertConfig> Function() configs,
  }) {
    return Obx(() {
      final list = configs();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: styles.AppTextStyles.bodyLarge
                  .copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(subtitle, style: styles.AppTextStyles.bodySmall),
          const SizedBox(height: 12),
          ...list.map((config) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _AlertToggleCard(
                  icon: controller.getAlertTypeIcon(config.alertType),
                  title: controller.getAlertTypeName(config.alertType),
                  enabled: config.enabled,
                  onChanged: (_) => controller.toggleAlert(config.alertType),
                  showDeliveryMode:
                      config.alertType == AlertType.ppeCompliance,
                  deliveryMode: config.deliveryMode,
                  onDeliveryModeChanged:
                      config.alertType == AlertType.ppeCompliance
                          ? (mode) =>
                              controller.setDeliveryMode(config.alertType, mode)
                          : null,
                ),
              )),
        ],
      );
    });
  }

  /// Commit changes button pinned above the bottom edge.
  Widget _buildCommitButton(AlertConfigController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Obx(() {
        return GestureDetector(
          onTap: controller.isLoading.value ? null : controller.commitChanges,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: -4,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: controller.isLoading.value
                ? const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Commit Changes',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      }),
    );
  }
}

/// Alert toggle card with icon chip, title, switch, and optional delivery tabs.
@immutable
class _AlertToggleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  final bool showDeliveryMode;
  final DeliveryMode deliveryMode;
  final ValueChanged<DeliveryMode>? onDeliveryModeChanged;

  const _AlertToggleCard({
    required this.icon,
    required this.title,
    required this.enabled,
    required this.onChanged,
    this.showDeliveryMode = false,
    this.deliveryMode = DeliveryMode.dual,
    this.onDeliveryModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled ? AppColors.accent : AppColors.textDisabled;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: enabled
              ? AppColors.accent.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.25)),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(title, style: styles.AppTextStyles.bodyLarge),
              ),
              Switch(
                value: enabled,
                onChanged: onChanged,
                activeColor: AppColors.accent,
                activeTrackColor: AppColors.accent.withValues(alpha: 0.3),
              ),
            ],
          ),
          if (showDeliveryMode && onDeliveryModeChanged != null) ...[
            const SizedBox(height: 12),
            _DeliveryModeTabs(
              selectedMode: deliveryMode,
              onModeChanged: onDeliveryModeChanged!,
            ),
          ],
        ],
      ),
    );
  }
}

/// Segmented control for Audio / Haptic / Dual delivery modes.
@immutable
class _DeliveryModeTabs extends StatelessWidget {
  final DeliveryMode selectedMode;
  final ValueChanged<DeliveryMode> onModeChanged;

  const _DeliveryModeTabs({
    required this.selectedMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _tab('Audio', DeliveryMode.audio),
          _tab('Haptic', DeliveryMode.haptic),
          _tab('Dual', DeliveryMode.dual),
        ],
      ),
    );
  }

  Widget _tab(String label, DeliveryMode mode) {
    final isSelected = mode == selectedMode;
    return Expanded(
      child: GestureDetector(
        onTap: () => onModeChanged(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: styles.AppTextStyles.bodySmall.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
