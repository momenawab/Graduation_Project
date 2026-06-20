import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../controllers/workers_list_controller.dart';
import '../widgets/common/ambient_backdrop.dart';
import '../widgets/common/bottom_nav_bar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart' as styles;
import '../../data/models/worker.dart' as model;
import '../../routes/app_routes.dart';

/// Workers List screen — modern layout with a summary header, KPI chips and a
/// glassy list of workers over the floating liquid-glass nav bar.
@immutable
class WorkersListScreen extends StatelessWidget {
  const WorkersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WorkersListController controller = Get.put(WorkersListController());

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      body: Stack(
        children: [
          const AmbientBackdrop(),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _Header(controller: controller)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.2, end: 0, curve: Curves.easeOut),
                _StatsRow(controller: controller)
                    .animate()
                    .fadeIn(delay: 120.ms, duration: 420.ms),
                _SearchBar(controller: controller)
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 420.ms),
                Expanded(child: _Content(controller: controller)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Brand header with title and live worker count.
class _Header extends StatelessWidget {
  final WorkersListController controller;
  const _Header({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
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
            child: const Icon(Icons.groups_outlined, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Workforce',
                    style: styles.AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 2),
                Text('Workers',
                    style: styles.AppTextStyles.headlineSmall.copyWith(fontSize: 22)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.ADD_WORKER),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
              ),
              child: const Icon(Icons.person_add_alt_1, color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

/// Summary KPI chips computed from the loaded workers.
class _StatsRow extends StatelessWidget {
  final WorkersListController controller;
  const _StatsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Per-worker violation counts are merged in from the violations-summary
      // endpoint; until that resolves, show counts as pending.
      final workers = controller.workers;
      final bool loaded = controller.statsLoaded.value;
      final int total = workers.length;
      final int flagged = workers.where((w) => w.violationCount > 0).length;
      final String withViolations = loaded ? '$flagged' : '—';
      final String compliant = loaded ? '${total - flagged}' : '—';

      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
        child: Row(
          children: [
            Expanded(
              child: _StatChip(
                icon: Icons.groups_2_outlined,
                value: '$total',
                label: 'Workers',
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatChip(
                icon: Icons.report_gmailerrorred_outlined,
                value: withViolations,
                label: 'Flagged',
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatChip(
                icon: Icons.verified_outlined,
                value: compliant,
                label: 'Compliant',
                color: AppColors.success,
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value,
              style: styles.AppTextStyles.headlineSmall.copyWith(fontSize: 18)),
          const SizedBox(height: 2),
          Text(label,
              style: styles.AppTextStyles.bodySmall.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}

/// Rounded glassy search field.
class _SearchBar extends StatelessWidget {
  final WorkersListController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                onChanged: controller.updateSearchQuery,
                style: styles.AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search by name, ID, or department...',
                  hintStyle: styles.AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading / error / empty / list states.
class _Content extends StatelessWidget {
  final WorkersListController controller;
  const _Content({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
            child: CircularProgressIndicator(color: AppColors.primary));
      }
      if (controller.errorMessage.value.isNotEmpty) {
        return _ErrorState(controller: controller);
      }

      final workers = controller.filteredWorkers;
      if (workers.isEmpty) return const _EmptyState();

      return RefreshIndicator(
        onRefresh: controller.refresh,
        color: AppColors.primary,
        backgroundColor: AppColors.cardBackground,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          itemCount: workers.length,
          itemBuilder: (context, index) {
            return WorkerCard(
              worker: workers[index],
              violationLevel:
                  controller.getViolationLevel(workers[index].violationCount),
              onTap: () => Get.toNamed(
                AppRoutes.WORKER_DETAILS
                    .replaceAll(':id', workers[index].id),
              ),
            ).animate().fadeIn(
                  delay: (40 * (index % 12)).ms,
                  duration: 300.ms,
                );
          },
        ),
      );
    });
  }
}

class _ErrorState extends StatelessWidget {
  final WorkersListController controller;
  const _ErrorState({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage.value,
              style: styles.AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: controller.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline,
                color: AppColors.textSecondary, size: 64),
            const SizedBox(height: 16),
            Text('No Workers Found',
                style: styles.AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('Add workers to get started',
                style: styles.AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

/// Modern worker card with photo, info and a violation badge.
@immutable
class WorkerCard extends StatelessWidget {
  final model.Worker worker;
  final String violationLevel;
  final VoidCallback onTap;

  const WorkerCard({
    required this.worker,
    required this.violationLevel,
    required this.onTap,
    super.key,
  });

  Color _getViolationColor() {
    switch (violationLevel) {
      case 'none':
        return AppColors.success;
      case 'low':
        return AppColors.warning;
      case 'medium':
        return const Color(0xFFFF9800);
      case 'high':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final violationColor = _getViolationColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.cardBackground,
              Color.lerp(AppColors.cardBackground, violationColor, 0.08)!,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: violationColor.withValues(alpha: 0.22)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: worker.photoUrl != null && worker.photoUrl!.isNotEmpty
                  ? Image.network(
                      worker.photoUrl!,
                      fit: BoxFit.cover,
                      width: 56,
                      height: 56,
                      errorBuilder: (_, _, _) => const Icon(
                          Icons.person_outline,
                          color: AppColors.primary,
                          size: 30),
                    )
                  : const Icon(Icons.person_outline,
                      color: AppColors.primary, size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    worker.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: styles.AppTextStyles.bodyLarge
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text('ID: ${worker.id}',
                      style: styles.AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(worker.department,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: styles.AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: violationColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: violationColor.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  Text('${worker.violationCount}',
                      style: styles.AppTextStyles.headlineSmall.copyWith(
                          color: violationColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 22)),
                  Text(
                    worker.violationCount == 1 ? 'Violation' : 'Violations',
                    style: styles.AppTextStyles.bodySmall
                        .copyWith(color: violationColor, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
