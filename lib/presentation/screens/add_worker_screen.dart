import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/worker_controller.dart';
import '../widgets/common/app_button.dart';
import '../widgets/common/app_input.dart';
import '../widgets/common/top_app_bar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/text_styles.dart' as styles;
import '../../data/models/ppe_item.dart';

/// Add Worker screen for registering new personnel.
/// Includes form validation, dropdowns, and PPE selection chips.
@immutable
class AddWorkerScreen extends StatelessWidget {
  const AddWorkerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WorkerController controller = Get.put(WorkerController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TopAppBar(
        title: AppStrings.addNewWorker,
        onBackPressed: () => Get.back(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Worker ID Input
              _buildWorkerIdInput(controller),

              const SizedBox(height: 24),

              // Full Name Input
              _buildFullNameInput(controller),

              const SizedBox(height: 24),

              // Department Dropdown
              _buildDepartmentDropdown(controller),

              const SizedBox(height: 24),

              // Job Title Dropdown
              _buildJobTitleDropdown(controller),

              const SizedBox(height: 24),

              // Required PPE Chips
              _buildRequiredPpeSection(controller),

              const SizedBox(height: 32),

              // Submit Button
              _buildSubmitButton(controller),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds Worker ID text input with validation.
  Widget _buildWorkerIdInput(WorkerController controller) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppInput(
            label: AppStrings.workerId,
            hintText: AppStrings.workerIdPlaceholder,
            value: controller.workerId.value,
            onChanged: controller.validateWorkerIdField,
            keyboardType: TextInputType.number,
            maxLength: 8,
            isRequired: true,
            errorText: controller.workerIdError.value.isEmpty
                ? null
                : controller.workerIdError.value,
            prefixIcon: Icons.badge,
          ),
        ],
      );
    });
  }

  /// Builds Full Name text input.
  Widget _buildFullNameInput(WorkerController controller) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppInput(
            label: AppStrings.fullName,
            hintText: AppStrings.fullNamePlaceholder,
            value: controller.fullName.value,
            onChanged: controller.validateFullNameField,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            maxLength: 100,
            isRequired: true,
            errorText: controller.fullNameError.value.isEmpty
                ? null
                : controller.fullNameError.value,
            prefixIcon: Icons.person,
          ),
        ],
      );
    });
  }

  /// Builds Department dropdown with predefined options.
  Widget _buildDepartmentDropdown(WorkerController controller) {
    return Obx(() {
      final hasError = controller.departmentError.value.isNotEmpty;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AppStrings.department,
                style: styles.AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                ' *',
                style: styles.AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasError ? AppColors.error : Colors.transparent,
                width: 1,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.department.value.isEmpty
                    ? null
                    : controller.department.value,
                hint: Text(
                  AppStrings.selectDepartment,
                  style: styles.AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                isExpanded: true,
                icon: const Icon(
                  Icons.expand_more,
                  color: AppColors.textSecondary,
                ),
                items: WorkerController.departments.map((String department) {
                  return DropdownMenuItem<String>(
                    value: department,
                    child: Text(
                      department,
                      style: styles.AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    controller.setDepartment(value);
                  }
                },
              ),
            ),
          ),
          if (hasError) ...[
            const SizedBox(height: 4),
            Text(
              controller.departmentError.value,
              style: styles.AppTextStyles.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
        ],
      );
    });
  }

  /// Builds Job Title dropdown with department-dependent options.
  Widget _buildJobTitleDropdown(WorkerController controller) {
    return Obx(() {
      final jobTitles = controller.getJobTitlesForDepartment();
      final isDisabled = controller.department.value.isEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AppStrings.jobTitle,
                style: styles.AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                ' *',
                style: styles.AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDisabled
                  ? AppColors.cardBackground.withOpacity(0.5)
                  : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: controller.jobTitleError.value.isNotEmpty
                    ? AppColors.error
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.jobTitle.value.isEmpty
                    ? null
                    : controller.jobTitle.value,
                hint: Text(
                  AppStrings.selectJobTitle,
                  style: styles.AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                isExpanded: true,
                icon: const Icon(
                  Icons.expand_more,
                  color: AppColors.textSecondary,
                ),
                items: jobTitles.map((String title) {
                  return DropdownMenuItem<String>(
                    value: title,
                    child: Text(
                      title,
                      style: styles.AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: isDisabled
                    ? null
                    : (String? value) {
                        if (value != null) {
                          controller.setJobTitle(value);
                        }
                      },
              ),
            ),
          ),
          if (controller.jobTitleError.value.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              controller.jobTitleError.value,
              style: styles.AppTextStyles.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
        ],
      );
    });
  }

  /// Builds Required PPE section with toggleable chips.
  Widget _buildRequiredPpeSection(WorkerController controller) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.requiredPpe,
            style: styles.AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: WorkerController.ppeDisplayNames.entries.map((entry) {
              final ppeType = entry.key;
              final displayName = entry.value;
              final isSelected = controller.isPpeSelected(ppeType);

              return _PpeChip(
                label: displayName,
                isSelected: isSelected,
                onTap: () => controller.togglePpe(ppeType),
              );
            }).toList(),
          ),
          if (controller.ppeError.value.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              controller.ppeError.value,
              style: styles.AppTextStyles.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
        ],
      );
    });
  }

  /// Builds submit button with loading state.
  Widget _buildSubmitButton(WorkerController controller) {
    return Obx(() {
      return SizedBox(
        width: double.infinity,
        child: AppButton(
          text: AppStrings.addWorkerButton,
          onPressed: controller.isLoading.value ? null : controller.submitForm,
          isLoading: controller.isLoading.value,
          backgroundColor: AppColors.primary,
        ),
      );
    });
  }
}

/// PPE selection chip widget.
@immutable
class _PpeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PpeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.textSecondary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Icon(Icons.check, size: 18, color: AppColors.primary)
            else
              Icon(Icons.add, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: styles.AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
