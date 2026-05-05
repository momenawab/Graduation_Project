import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/workers_list_controller.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/bottom_nav_bar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart' as styles;
import '../../data/models/worker.dart' as model;
import '../../routes/app_routes.dart';

/// Workers List screen showing all registered workers.
@immutable
class WorkersListScreen extends StatelessWidget {
  const WorkersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WorkersListController controller = Get.put(WorkersListController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top app bar
            _buildTopAppBar(),

            // Search bar
            _buildSearchBar(controller),

            // Content area
            Expanded(child: _buildContent(controller)),

            // Bottom navigation
            const BottomNavBar(currentIndex: 1),
          ],
        ),
      ),
    );
  }

  /// Builds top app bar with title.
  Widget _buildTopAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.people,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Workers',
            style: styles.AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds search bar.
  Widget _buildSearchBar(WorkersListController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              color: AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                onChanged: controller.updateSearchQuery,
                style: styles.AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search workers by name, ID, or department...',
                  hintStyle: styles.AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
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

  /// Builds main content area.
  Widget _buildContent(WorkersListController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingState();
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return _buildErrorState(controller);
      }

      final workers = controller.filteredWorkers;

      if (workers.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: controller.refresh,
        color: AppColors.primary,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: workers.length,
          itemBuilder: (context, index) {
            return WorkerCard(
              worker: workers[index],
              violationLevel: controller.getViolationLevel(workers[index].violationCount),
              onTap: () => Get.toNamed(
                AppRoutes.WORKER_DETAILS.replaceAll(':id', workers[index].id),
              ),
            );
          },
        ),
      );
    });
  }

  /// Builds loading state.
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }

  /// Builds error state.
  Widget _buildErrorState(WorkersListController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage.value,
              style: styles.AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
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

  /// Builds empty state.
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              color: AppColors.textSecondary,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No Workers Found',
              style: styles.AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add workers to get started',
              style: styles.AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Worker card widget for displaying a single worker.
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
      child: AppCard(
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Worker photo or placeholder
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: worker.faceId != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: const Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      )
                    : const Icon(
                        Icons.person_outline,
                        color: AppColors.primary,
                        size: 32,
                      ),
              ),

              const SizedBox(width: 16),

              // Worker info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      worker.fullName,
                      style: styles.AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${worker.id}',
                      style: styles.AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      worker.department,
                      style: styles.AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Violation count badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: violationColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: violationColor.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '${worker.violationCount}',
                      style: styles.AppTextStyles.headlineSmall.copyWith(
                        color: violationColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      worker.violationCount == 1 ? 'Violation' : 'Violations',
                      style: styles.AppTextStyles.bodySmall.copyWith(
                        color: violationColor,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
