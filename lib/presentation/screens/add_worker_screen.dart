import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/worker_controller.dart';
import '../../data/services/face/face_quality_service.dart';
import '../widgets/common/ambient_backdrop.dart';
import '../widgets/common/app_button.dart';
import '../widgets/common/app_input.dart';
import '../widgets/common/top_app_bar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/text_styles.dart' as styles;

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
      body: Stack(
        children: [
          const AmbientBackdrop(),
          SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Photo Picker Section
              _buildPhotoPickerSection(controller)
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),

              const SizedBox(height: 24),

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

              // Account Creation Section
              _buildAccountCreationSection(controller),

              const SizedBox(height: 32),

              // Submit Button
              _buildSubmitButton(controller),

              const SizedBox(height: 16),
            ],
          ),
        ),
          ),
        ],
      ),
    );
  }

  /// Builds the guided multi-angle face capture section (front / left / right).
  /// Each shot is validated on-device before it is accepted.
  Widget _buildPhotoPickerSection(WorkerController controller) {
    return Obx(() {
      return Column(
        children: [
          Text(
            'Face Enrollment',
            style: styles.AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Capture the face from 3 angles for reliable recognition',
            style: styles.AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              WorkerController.captureAngles.length,
              (index) => _buildCaptureSlot(controller, index),
            ),
          ),
          if (controller.photoError.value.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              controller.photoError.value,
              style: styles.AppTextStyles.bodySmall.copyWith(
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      );
    });
  }

  /// Builds a single guided capture slot for the given angle [index].
  Widget _buildCaptureSlot(WorkerController controller, int index) {
    return Obx(() {
      final angle = WorkerController.captureAngles[index];
      final photo = controller.capturedPhotos[index];
      final slotError = controller.photoSlotErrors[index];
      final isAnalyzing = controller.analyzingSlot.value == index;
      final hasPhoto = photo != null;
      final hasError = slotError.isNotEmpty;

      return SizedBox(
        width: 96,
        child: Column(
          children: [
            GestureDetector(
              onTap: isAnalyzing ? null : () => controller.captureForSlot(index),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.cardBackground,
                      border: Border.all(
                        color: hasError
                            ? AppColors.error
                            : hasPhoto
                                ? AppColors.primary
                                : AppColors.textSecondary.withOpacity(0.3),
                        width: 2,
                      ),
                      image: hasPhoto
                          ? DecorationImage(
                              image: FileImage(photo),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: hasPhoto
                        ? null
                        : Icon(
                            Icons.camera_alt,
                            size: 26,
                            color: AppColors.textSecondary,
                          ),
                  ),
                  if (isAnalyzing)
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.45),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  if (hasPhoto && !isAnalyzing)
                    Positioned(
                      top: 0,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => controller.removeSlot(index),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.error,
                            border:
                                Border.all(color: AppColors.background, width: 2),
                          ),
                          child: const Icon(Icons.close,
                              size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  if (hasPhoto && !isAnalyzing)
                    Positioned(
                      bottom: 2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                        child: const Icon(Icons.check,
                            size: 12, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              angle.label,
              style: styles.AppTextStyles.bodySmall.copyWith(
                color: hasPhoto ? AppColors.primary : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              hasError ? slotError : angle.hint,
              style: styles.AppTextStyles.bodySmall.copyWith(
                color: hasError ? AppColors.error : AppColors.textSecondary,
                fontSize: 9.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
          ],
        ),
      );
    });
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
                items: WorkerController.departmentOptions.entries
                    .map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(
                      entry.value,
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

  /// Builds the account creation section with toggle and form fields.
  Widget _buildAccountCreationSection(WorkerController controller) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.textSecondary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person_add,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Worker Login Account',
                        style: styles.AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Allow this worker to log into the app using their own credentials',
                        style: styles.AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: controller.createAccount.value,
                  onChanged: controller.toggleCreateAccount,
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),

          // Account fields (shown when toggle is on)
          if (controller.createAccount.value) ...[
            const SizedBox(height: 16),

            // Username Input
            _buildUsernameInput(controller),

            const SizedBox(height: 16),

            // Password Input
            _buildPasswordInput(controller),

            const SizedBox(height: 16),

            // Email Input (optional)
            _buildEmailInput(controller),
          ],
        ],
      );
    });
  }

  /// Builds username input field.
  Widget _buildUsernameInput(WorkerController controller) {
    return Obx(() {
      return AppInput(
        label: 'Username',
        hintText: 'Enter login username',
        value: controller.username.value,
        onChanged: controller.validateUsernameField,
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.none,
        maxLength: 30,
        isRequired: controller.createAccount.value,
        errorText: controller.usernameError.value.isEmpty
            ? null
            : controller.usernameError.value,
        prefixIcon: Icons.person_outline,
      );
    });
  }

  /// Builds password input field.
  Widget _buildPasswordInput(WorkerController controller) {
    return Obx(() {
      return AppInput(
        label: 'Password',
        hintText: 'Enter password (min 6 characters)',
        value: controller.password.value,
        onChanged: controller.validatePasswordField,
        keyboardType: TextInputType.visiblePassword,
        textCapitalization: TextCapitalization.none,
        maxLength: 128,
        obscureText: true,
        isRequired: controller.createAccount.value,
        errorText: controller.passwordError.value.isEmpty
            ? null
            : controller.passwordError.value,
        prefixIcon: Icons.lock_outline,
      );
    });
  }

  /// Builds email input field (optional).
  Widget _buildEmailInput(WorkerController controller) {
    return Obx(() {
      return AppInput(
        label: 'Email (Optional)',
        hintText: 'Enter email address',
        value: controller.email.value,
        onChanged: (value) => controller.email.value = value,
        keyboardType: TextInputType.emailAddress,
        textCapitalization: TextCapitalization.none,
        prefixIcon: Icons.email_outlined,
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
