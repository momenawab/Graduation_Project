import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/ppe_item.dart';
import '../../data/services/api/auth_api_service.dart';
import '../../data/services/api/worker_api.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';

/// Controller for worker registration and management screen.
/// Manages form state, validation, and submission.
class WorkerController extends GetxController {
  /// Auth API service for creating worker accounts
  late final AuthApiService _authApiService;
  late final WorkerApi _workerApi;
  final ImagePicker _picker = ImagePicker();

  // Photo state
  final Rx<File?> selectedPhoto = Rx<File?>(null);
  final RxString photoError = ''.obs;

  // Form state observables
  final RxString workerId = ''.obs;
  final RxString fullName = ''.obs;
  final RxString department = ''.obs;
  final RxString jobTitle = ''.obs;
  final RxList<PPEType> requiredPpe = <PPEType>[].obs;

  // Account creation section
  final RxBool createAccount = false.obs;
  final RxString username = ''.obs;
  final RxString password = ''.obs;
  final RxString email = ''.obs;
  final RxString usernameError = ''.obs;
  final RxString passwordError = ''.obs;

  // Validation error observables
  final RxString workerIdError = ''.obs;
  final RxString fullNameError = ''.obs;
  final RxString departmentError = ''.obs;
  final RxString jobTitleError = ''.obs;
  final RxString ppeError = ''.obs;

  // Loading state
  final RxBool isLoading = false.obs;

  // Department options
  /// Departments mirror the backend's `Worker.DEPARTMENT_CHOICES`
  /// (slug submitted to the API → human-readable label shown in the dropdown).
  /// The backend has no endpoint to fetch these, so they are kept aligned here.
  static const Map<String, String> departmentOptions = {
    'construction': 'Construction',
    'manufacturing': 'Manufacturing',
    'maintenance': 'Maintenance',
    'warehouse': 'Warehouse',
    'laboratory': 'Laboratory',
    'cleaning': 'Cleaning',
    'other': 'Other',
  };

  /// Backend slugs, used as dropdown values.
  static List<String> get departments => departmentOptions.keys.toList();

  // Job title options by department slug. `position` is free-text on the
  // backend, so these are a curated UX list per department.
  static const Map<String, List<String>> jobTitlesByDepartment = {
    'construction': ['Operator', 'Supervisor', 'Foreman', 'Laborer'],
    'manufacturing': ['Operator', 'Technician', 'Supervisor', 'Quality Inspector'],
    'maintenance': ['Technician', 'Electrician', 'Mechanic', 'Lead'],
    'warehouse': ['Picker', 'Forklift Operator', 'Supervisor', 'Logistics Lead'],
    'laboratory': ['Lab Technician', 'Analyst', 'Safety Officer'],
    'cleaning': ['Cleaner', 'Sanitation Worker', 'Supervisor'],
    'other': ['Worker', 'Supervisor', 'Manager'],
  };

  // PPE options the detection model can actually detect (C1). safetyGlasses
  // and earProtection are intentionally excluded so workers aren't assigned PPE
  // that would always read as "missing".
  static const Map<PPEType, String> ppeDisplayNames = {
    PPEType.hardHat: 'Hard Hat',
    PPEType.vest: 'Vest',
    PPEType.gloves: 'Gloves',
    PPEType.steelToedBoots: 'Steel-toed Boots',
  };

  // Mock existing worker IDs for duplicate check
  final RxList<String> existingWorkerIds = <String>['12345678', '87654321'].obs;

  @override
  void onInit() {
    super.onInit();
    _authApiService = Get.find<AuthApiService>();
    _workerApi = Get.find<WorkerApi>();
    _loadExistingWorkers();
  }

  @override
  void onClose() {
    selectedPhoto.close();
    photoError.close();
    workerId.close();
    fullName.close();
    department.close();
    jobTitle.close();
    requiredPpe.close();
    createAccount.close();
    username.close();
    password.close();
    email.close();
    usernameError.close();
    passwordError.close();
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

  /// Pick photo from camera.
  Future<void> pickPhotoFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1080,
        maxHeight: 1080,
      );
      if (image != null) {
        selectedPhoto.value = File(image.path);
        photoError.value = '';
      }
    } catch (e) {
      photoError.value = 'Failed to capture photo';
    }
  }

  /// Pick photo from gallery.
  Future<void> pickPhotoFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1080,
        maxHeight: 1080,
      );
      if (image != null) {
        selectedPhoto.value = File(image.path);
        photoError.value = '';
      }
    } catch (e) {
      photoError.value = 'Failed to select photo';
    }
  }

  /// Remove selected photo.
  void removePhoto() {
    selectedPhoto.value = null;
    photoError.value = '';
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

    // Validate photo
    if (selectedPhoto.value == null) {
      photoError.value = 'A face photo is required for worker identification';
      isValid = false;
    }

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

  /// Submits the worker registration form (legacy - uses new method).
  Future<void> submitForm() async {
    await submitFormWithAccount();
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
    return photoError.value.isEmpty &&
        workerIdError.value.isEmpty &&
        fullNameError.value.isEmpty &&
        departmentError.value.isEmpty &&
        jobTitleError.value.isEmpty &&
        ppeError.value.isEmpty &&
        selectedPhoto.value != null &&
        workerId.value.isNotEmpty &&
        fullName.value.isNotEmpty &&
        department.value.isNotEmpty &&
        jobTitle.value.isNotEmpty &&
        requiredPpe.isNotEmpty;
  }

  /// Toggle account creation
  void toggleCreateAccount(bool value) {
    createAccount.value = value;
    if (!value) {
      username.value = '';
      password.value = '';
      email.value = '';
      usernameError.value = '';
      passwordError.value = '';
    }
  }

  /// Validates username field
  void validateUsernameField(String value) {
    username.value = value;
    if (value.isEmpty && createAccount.value) {
      usernameError.value = 'Username is required';
    } else if (value.length < 3) {
      usernameError.value = 'Username must be at least 3 characters';
    } else {
      usernameError.value = '';
    }
  }

  /// Validates password field
  void validatePasswordField(String value) {
    password.value = value;
    if (value.isEmpty && createAccount.value) {
      passwordError.value = 'Password is required';
    } else if (value.length < 6) {
      passwordError.value = 'Password must be at least 6 characters';
    } else {
      passwordError.value = '';
    }
  }

  /// Validates account section
  bool validateAccountSection() {
    if (!createAccount.value) return true;

    bool isValid = true;

    if (username.value.isEmpty) {
      usernameError.value = 'Username is required';
      isValid = false;
    } else if (username.value.length < 3) {
      usernameError.value = 'Username must be at least 3 characters';
      isValid = false;
    }

    if (password.value.isEmpty) {
      passwordError.value = 'Password is required';
      isValid = false;
    } else if (password.value.length < 6) {
      passwordError.value = 'Password must be at least 6 characters';
      isValid = false;
    }

    return isValid;
  }

  /// Validates all form fields including account section.
  bool validateFormWithAccount() {
    return validateForm() && validateAccountSection();
  }

  /// Submits the worker registration form with optional account creation.
  Future<void> submitFormWithAccount() async {
    if (!validateFormWithAccount()) {
      return;
    }

    try {
      isLoading.value = true;

      // Save worker with photo to backend
      await _workerApi.addWorkerWithPhoto(
        workerId: workerId.value,
        name: fullName.value,
        photo: selectedPhoto.value!,
        department: department.value.isNotEmpty ? department.value : null,
        position: jobTitle.value.isNotEmpty ? jobTitle.value : null,
        requiredPpe: requiredPpe.isNotEmpty
            ? requiredPpe.map((e) => e.name).toList()
            : null,
      );

      // Add to existing IDs for duplicate check
      existingWorkerIds.add(workerId.value);

      // Create worker account if requested
      if (createAccount.value) {
        await _authApiService.createWorkerAccount(
          workerId: workerId.value,
          username: username.value,
          password: password.value,
          email: email.value.isNotEmpty ? email.value : null,
        );
      }

      // Show success message
      Get.snackbar(
        'Success',
        createAccount.value
            ? 'Worker "${fullName.value}" and account created successfully.'
            : 'Worker "${fullName.value}" has been added successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Reset form and navigate back
      resetForm();
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add worker: ${e.toString()}',
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
    selectedPhoto.value = null;
    photoError.value = '';
    workerId.value = '';
    fullName.value = '';
    department.value = '';
    jobTitle.value = '';
    requiredPpe.clear();
    createAccount.value = false;
    username.value = '';
    password.value = '';
    email.value = '';

    workerIdError.value = '';
    fullNameError.value = '';
    departmentError.value = '';
    jobTitleError.value = '';
    ppeError.value = '';
    usernameError.value = '';
    passwordError.value = '';
  }
}
