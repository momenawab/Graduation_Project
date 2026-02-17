import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/instructions_controller.dart';
import '../widgets/common/app_card.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/text_styles.dart' as styles;
import '../../data/services/api/instructions_api.dart';

/// Instructions screen with tutorials, FAQs, and search functionality.
@immutable
class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final InstructionsController controller = Get.put(
      InstructionsController(
        instructionsApi: InstructionsApi(apiClient: Get.find()),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top app bar with back button, title, and help icon
            _buildTopAppBar(),

            // Content area
            Expanded(child: _buildContent(controller)),

            // Bottom navigation
            const _InstructionsBottomNav(currentIndex: 3),
          ],
        ),
      ),
    );
  }

  /// Builds top app bar with back button, title, and help icon.
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
                AppStrings.instructions,
                style: styles.AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                ),
              ),
            ],
          ),

          // Help icon button
          GestureDetector(
            onTap: () {
              // TODO: Open help dialog or navigate to help screen
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.help_outline,
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
  Widget _buildContent(InstructionsController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Search bar
          _buildSearchBar(controller),

          const SizedBox(height: 16),

          // Content tabs
          _buildContentTabs(controller),

          const SizedBox(height: 16),

          // Featured Tutorials section
          _buildFeaturedTutorials(controller),

          const SizedBox(height: 16),

          // Common Questions section
          _buildCommonQuestions(controller),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Builds search bar with magnifying glass icon.
  Widget _buildSearchBar(InstructionsController controller) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                onChanged: controller.updateSearchQuery,
                style: styles.AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: AppStrings.searchTutorials,
                  hintStyle: styles.AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (controller.searchQuery.value.isNotEmpty)
              GestureDetector(
                onTap: () => controller.updateSearchQuery(''),
                child: const Icon(
                  Icons.clear,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
          ],
        ),
      );
    });
  }

  /// Builds content tabs with active state highlighting.
  Widget _buildContentTabs(InstructionsController controller) {
    return Obx(() {
      return Row(
        children: List.generate(
          InstructionsController.tabLabels.length,
          (index) => _TabItem(
            label: InstructionsController.tabLabels[index],
            isActive: controller.selectedTab.value == index,
            onTap: () => controller.selectTab(index),
          ),
        ),
      );
    });
  }

  /// Builds Featured Tutorials section with card-based layout.
  Widget _buildFeaturedTutorials(InstructionsController controller) {
    return Obx(() {
      final tutorials = controller.getFilteredTutorials();

      if (tutorials.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              AppStrings.featuredTutorials,
              style: styles.AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Tutorial cards
          ...tutorials.map((tutorial) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TutorialCard(
                tutorial: tutorial,
                onTap: () => controller.showTutorialDetail(tutorial),
                iconColor: controller.getColorForCategory(tutorial['category']),
                icon: controller.getIconForTutorial(tutorial['icon']),
              ),
            );
          }).toList(),
        ],
      );
    });
  }

  /// Builds Common Questions section with expandable cards.
  Widget _buildCommonQuestions(InstructionsController controller) {
    return Obx(() {
      final faqs = controller.getFilteredFaqs();

      if (faqs.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              AppStrings.commonQuestions,
              style: styles.AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // FAQ cards
          ...faqs.map((faq) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _FaqCard(
                faq: faq,
                isExpanded: controller.expandedFaqs.contains(faq['id']),
                onTap: () => controller.toggleFaqExpansion(faq['id']),
              ),
            );
          }).toList(),
        ],
      );
    });
  }
}

/// Tab item widget for content tabs.
@immutable
class _TabItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: styles.AppTextStyles.bodyMedium.copyWith(
              color: isActive ? Colors.white : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

/// Tutorial card widget.
@immutable
class _TutorialCard extends StatelessWidget {
  final Map<String, dynamic> tutorial;
  final VoidCallback onTap;
  final Color iconColor;
  final IconData icon;

  const _TutorialCard({
    required this.tutorial,
    required this.onTap,
    required this.iconColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),

            const SizedBox(width: 16),

            // Title and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tutorial['title']?.toString() ?? '',
                    style: styles.AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tutorial['description']?.toString() ?? '',
                    style: styles.AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Right arrow
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

/// FAQ card widget with expandable content.
@immutable
class _FaqCard extends StatelessWidget {
  final Map<String, dynamic> faq;
  final bool isExpanded;
  final VoidCallback onTap;

  const _FaqCard({
    required this.faq,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question and arrow
            Row(
              children: [
                Expanded(
                  child: Text(
                    faq['question']?.toString() ?? '',
                    style: styles.AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                  size: 24,
                ),
              ],
            ),

            // Answer (expanded)
            if (isExpanded) ...[
              const SizedBox(height: 12),
              Text(
                faq['answer']?.toString() ?? '',
                style: styles.AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Instructions bottom navigation widget.
@immutable
class _InstructionsBottomNav extends StatelessWidget {
  final int currentIndex;

  const _InstructionsBottomNav({required this.currentIndex});

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
            icon: Icons.videocam,
            label: 'Real-time',
            isActive: currentIndex == 0,
            onTap: () => Get.toNamed('/monitoring'),
          ),
          _NavItem(
            icon: Icons.cloud_upload,
            label: 'Upload',
            isActive: currentIndex == 1,
            onTap: () => Get.toNamed('/upload'),
          ),
          _NavItem(
            icon: Icons.people,
            label: 'Workers',
            isActive: currentIndex == 2,
            onTap: () => Get.toNamed('/worker/add'),
          ),
          _NavItem(
            icon: Icons.insert_chart,
            label: 'Reports',
            isActive: currentIndex == 3,
            onTap: () => Get.toNamed('/reports'),
          ),
          _NavItem(
            icon: Icons.settings,
            label: 'Settings',
            isActive: currentIndex == 4,
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
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: styles.AppTextStyles.bodySmall.copyWith(
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
