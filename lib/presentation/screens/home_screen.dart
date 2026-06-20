import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../widgets/common/ambient_backdrop.dart';
import '../widgets/common/bottom_nav_bar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/text_styles.dart' as styles;

/// Home screen — modern control-center layout with a live-status hero,
/// quick stats and a bento grid of actions, over a floating liquid-glass nav bar.
@immutable
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: AppColors.background,
      // Let page content flow behind the floating glass nav bar.
      extendBody: true,
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      body: Stack(
        children: [
          // Ambient brand glow behind the content.
          const AmbientBackdrop(),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(controller: controller)
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.2, end: 0, curve: Curves.easeOut),
                  const SizedBox(height: 20),
                  _LiveMonitoringHero(controller: controller)
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 450.ms)
                      .slideY(begin: 0.15, end: 0, curve: Curves.easeOut),
                  const SizedBox(height: 16),
                  _StatsRow(controller: controller)
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 450.ms)
                      .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
                  const SizedBox(height: 28),
                  Text(
                    'Quick Actions',
                    style: styles.AppTextStyles.headlineSmall.copyWith(
                      fontSize: 18,
                      letterSpacing: 0.2,
                    ),
                  ).animate().fadeIn(delay: 280.ms, duration: 400.ms),
                  const SizedBox(height: 14),
                  _ActionsGrid(controller: controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Greeting row with brand mark and profile button.
class _Header extends StatelessWidget {
  final HomeController controller;
  const _Header({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
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
          child: const Icon(Icons.shield_outlined, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back',
                style: styles.AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                AppStrings.appName,
                style: styles.AppTextStyles.headlineSmall.copyWith(fontSize: 22),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: controller.navigateToSettings,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.person_outline, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

/// Large hero card showing live system status with an animated pulse.
class _LiveMonitoringHero extends StatelessWidget {
  final HomeController controller;
  const _LiveMonitoringHero({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final Color statusColor = controller.getStatusColor();
      final int cameras = controller.systemStatus.value.activeCameras;

      return GestureDetector(
        onTap: controller.navigateToMonitoring,
        child: Container(
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
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 28,
                spreadRadius: -6,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _PulseDot(color: statusColor),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.activeMonitoring,
                    style: styles.AppTextStyles.label.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: controller.refreshSystemStatus,
                    child: const Icon(Icons.refresh,
                        color: AppColors.textSecondary, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                AppStrings.allSystemsNormal,
                style: styles.AppTextStyles.headlineMedium.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 6),
              Text(
                '$cameras cameras streaming in real time',
                style: styles.AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    'Open live view',
                    style: styles.AppTextStyles.label.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward,
                      color: AppColors.accent, size: 18),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

/// Animated pulsing status dot.
class _PulseDot extends StatelessWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    )
        .animate(onPlay: (c) => c.repeat())
        .scale(
          duration: 900.ms,
          begin: const Offset(1, 1),
          end: const Offset(1.6, 1.6),
        )
        .fadeOut(duration: 900.ms);
  }
}

/// Row of three compact KPI chips.
class _StatsRow extends StatelessWidget {
  final HomeController controller;
  const _StatsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool loaded = controller.statsLoaded.value;
      final int cameras = controller.systemStatus.value.activeCameras;
      final String compliance =
          loaded ? '${controller.complianceRate.value}%' : '—';
      final String alerts =
          loaded ? '${controller.alertCount.value}' : '—';
      return Row(
        children: [
          Expanded(
            child: _StatChip(
              icon: Icons.videocam_outlined,
              value: '$cameras',
              label: 'Cameras',
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatChip(
              icon: Icons.verified_outlined,
              value: compliance,
              label: 'Compliance',
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatChip(
              icon: Icons.notifications_active_outlined,
              value: alerts,
              label: 'Alerts',
              color: AppColors.warning,
            ),
          ),
        ],
      );
    });
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: styles.AppTextStyles.headlineSmall.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: styles.AppTextStyles.bodySmall.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

/// Bento grid of primary actions.
class _ActionsGrid extends StatelessWidget {
  final HomeController controller;
  const _ActionsGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    final actions = <_ActionData>[
      _ActionData(Icons.videocam_rounded, 'Monitoring', 'Real-time detection',
          AppColors.primary, controller.navigateToMonitoring),
      _ActionData(Icons.bar_chart_rounded, 'Reports', 'Safety analytics',
          AppColors.accent, controller.navigateToReports),
      _ActionData(Icons.person_add_alt_1_rounded, 'Add Worker',
          'Worker management', AppColors.success, controller.navigateToAddWorker),
      _ActionData(Icons.tune_rounded, 'Thresholds', 'Alert settings',
          AppColors.warning, controller.navigateToAlertConfig),
      _ActionData(Icons.cloud_upload_rounded, 'Media', 'Upload images',
          AppColors.accent, controller.navigateToUploadDetection),
      _ActionData(Icons.person_search_rounded, 'Workers Monitor',
          'Scan & identify', AppColors.primary, controller.navigateToWorkerMonitor),
      _ActionData(Icons.videocam_rounded, 'Cameras', 'Manage & PPE policy',
          AppColors.accent, controller.navigateToCameras),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, i) {
        return _ActionTile(data: actions[i])
            .animate()
            .fadeIn(delay: (300 + i * 70).ms, duration: 380.ms)
            .slideY(begin: 0.2, end: 0, curve: Curves.easeOut);
      },
    );
  }
}

class _ActionData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _ActionData(
      this.icon, this.title, this.subtitle, this.color, this.onTap);
}

class _ActionTile extends StatelessWidget {
  final _ActionData data;
  const _ActionTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.cardBackground,
              Color.lerp(AppColors.cardBackground, data.color, 0.12)!,
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: data.color.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: data.color.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: data.color.withValues(alpha: 0.3)),
                  ),
                  child: Icon(data.icon, color: data.color, size: 24),
                ),
                Icon(Icons.arrow_outward_rounded,
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                    size: 18),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: styles.AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: styles.AppTextStyles.bodySmall.copyWith(fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
