import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/ppe_item.dart';
import '../../data/models/worker.dart' as worker_model;
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../routes/app_routes.dart';

/// Controller for worker registration and management screen.
/// Manages form state, validation, and submission.
class WorkerController extends GetxController {
  // Form state observables
  final RxString workerId = ''.obs;
  final RxString fullName = ''.obs;
  final RxString department = ''.obs;
  final RxString jobTitle = ''.obs;
  final RxList<PPEType> requiredPpe = <PPEType>[].obs;

  // Validation error observables
  final RxString workerIdError = ''.obs;
  final RxString fullNameError = ''.obs;
  final RxString departmentError = ''.obs;
  final RxString jobTitleError = ''.obs;
  final RxString ppeError = ''.obs;

  // Loading state
  final RxBool isLoading = false.obs;

  // Department options
  static const List<String> departments = [
    'Production',
    'Maintenance',
    'Safety',
  ];

  // Job title options by department
  static const Map<String, List<String>> jobTitlesByDepartment = {
    'Production': ['Operator', 'Supervisor', 'Technician'],
    'Maintenance': ['Technician', 'Lead', 'Supervisor'],
    'Safety': ['Inspector', 'Officer', 'Manager'],
  };

  // PPE options with display names
  static const Map<PPEType, String> ppeDisplayNames = {
    PPEType.hardHat: 'Hard Hat',
    PPEType.safetyGlasses: 'Safety Glasses',
    PPEType.vest: 'Vest',
    PPEType.gloves: 'Gloves',
    PPEType.steelToedBoots: 'Steel-toed Boots',
    PPEType.earProtection: 'Ear Protection',
  };

  // Mock existing worker IDs for duplicate check
  final RxList<String> existingWorkerIds = <String>['12345678', '87654321'].obs;

  @override
  void onInit() {
    super.onInit();
    _loadExistingWorkers();
  }

  @override
  void onClose() {
    workerId.close();
    fullName.close();
    department.close();
    jobTitle.close();
    requiredPpe.close();
    workerIdError.close();
    fullNameError.close();
    departmentError.close();
    jobTitleError.close();
    ppeError.close();
    isLoading.close();
    existingWorkerIds.close();
    super.onClose();
  }

  /// Loads existing worker IDs from repository/API.
  Future<void> _loadExistingWorkers() async {
    try {
      // TODO: Load actual workers from WorkerRepository
      // For now, using mock data
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      // Handle error silently for now
    }
  }

  /// Validates worker ID field.
  void validateWorkerIdField(String value) {
    workerId.value = value;
    final error = AppValidators.validateWorkerId(value);
    workerIdError.value = error ?? '';

    // Check for duplicate ID
    if (error == null && existingWorkerIds.contains(value)) {
      workerIdError.value = AppStrings.workerIdAlreadyExists;
    }
  }

  /// Validates full name field.
  void validateFullNameField(String value) {
    fullName.value = value;
    final error = AppValidators.validateFullName(value);
    fullNameError.value = error ?? '';
  }

  /// Sets the selected department and clears job title if department changes.
  void setDepartment(String value) {
    department.value = value;
    departmentError.value = '';
    // Clear job title when department changes
    jobTitle.value = '';
    jobTitleError.value = '';
  }

  /// Sets the selected job title.
  void setJobTitle(String value) {
    jobTitle.value = value;
    jobTitleError.value = '';
  }

  /// Toggles PPE item selection.
  void togglePpe(PPEType ppeType) {
    if (requiredPpe.contains(ppeType)) {
      requiredPpe.remove(ppeType);
    } else {
      requiredPpe.add(ppeType);
    }
    ppeError.value = '';
  }

  /// Checks if a PPE item is selected.
  bool isPpeSelected(PPEType ppeType) {
    return requiredPpe.contains(ppeType);
  }

  /// Validates all form fields.
  bool validateForm() {
    bool isValid = true;

    // Validate worker ID
    final workerIdValidation = AppValidators.validateWorkerId(workerId.value);
    workerIdError.value = workerIdValidation ?? '';
    if (workerIdValidation != null) {
      isValid = false;
    } else if (existingWorkerIds.contains(workerId.value)) {
      workerIdError.value = AppStrings.workerIdAlreadyExists;
      isValid = false;
    }

    // Validate full name
    final fullNameValidation = AppValidators.validateFullName(fullName.value);
    fullNameError.value = fullNameValidation ?? '';
    if (fullNameValidation != null) {
      isValid = false;
    }

    // Validate department
    if (department.value.isEmpty) {
      departmentError.value = AppStrings.pleaseSelectDepartment;
      isValid = false;
    }

    // Validate job title
    if (jobTitle.value.isEmpty) {
      jobTitleError.value = AppStrings.pleaseSelectJobTitle;
      isValid = false;
    }

    // Validate required PPE
    if (requiredPpe.isEmpty) {
      ppeError.value = AppStrings.atLeastOnePpeRequired;
      isValid = false;
    }

    return isValid;
  }

  /// Submits the worker registration form.
  Future<void> submitForm() async {
    if (!validateForm()) {
      return;
    }

    try {
      isLoading.value = true;

      // Create worker object
      final worker = worker_model.Worker(
        id: workerId.value,
        fullName: fullName.value,
        department: department.value,
        jobTitle: jobTitle.value,
        requiredPpe: requiredPpe.toList(),
        createdAt: DateTime.now(),
        violationCount: 0,
      );

      // TODO: Save worker to WorkerRepository
      await Future.delayed(const Duration(seconds: 1));

      // Add to existing IDs for duplicate check
      existingWorkerIds.add(worker.id);

      // Show success message
      Get.snackbar(
        'Success',
        'Worker "${worker.fullName}" has been added successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Navigate to worker list or back
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add worker. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFF44336),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Resets the form to initial state.
  void resetForm() {
    workerId.value = '';
    fullName.value = '';
    department.value = '';
    jobTitle.value = '';
    requiredPpe.clear();

    workerIdError.value = '';
    fullNameError.value = '';
    departmentError.value = '';
    jobTitleError.value = '';
    ppeError.value = '';
  }

  /// Gets job titles for the selected department.
  List<String> getJobTitlesForDepartment() {
    if (department.value.isEmpty) {
      return [];
    }
    return jobTitlesByDepartment[department.value] ?? [];
  }

  /// Checks if the form is valid.
  bool get isFormValid {
    return workerIdError.value.isEmpty &&
        fullNameError.value.isEmpty &&
        departmentError.value.isEmpty &&
        jobTitleError.value.isEmpty &&
        ppeError.value.isEmpty &&
        workerId.value.isNotEmpty &&
        fullName.value.isNotEmpty &&
        department.value.isNotEmpty &&
        jobTitle.value.isNotEmpty &&
        requiredPpe.isNotEmpty;
  }
}
