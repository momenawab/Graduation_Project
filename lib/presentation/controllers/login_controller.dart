import 'package:get/get.dart';
import 'package:safesight/data/services/api/api_client.dart';
import 'package:safesight/data/services/api/auth_api_service.dart';
import 'package:safesight/data/services/storage_service.dart';
import 'package:safesight/data/services/push_service.dart';
import 'package:safesight/routes/app_routes.dart';

/// Controller for unified login screen.
///
/// Handles login for both admin and worker users.
/// Backend determines role and routes accordingly.
class LoginController extends GetxController {
  /// Auth API service
  late final AuthApiService _authApiService;

  /// Storage service
  StorageService get _storageService => Get.find<StorageService>();

  @override
  void onInit() {
    super.onInit();
    _authApiService = Get.find<AuthApiService>();
  }

  /// Observable for loading state
  final RxBool isLoading = false.obs;

  /// Observable for error message
  final RxString errorMessage = ''.obs;

  /// Observable for password visibility
  final RxBool isPasswordVisible = false.obs;

  /// Text editing controllers
  final RxString username = ''.obs;
  final RxString password = ''.obs;

  /// Validate login form
  bool get isValid => username.value.isNotEmpty && password.value.isNotEmpty;

  /// User login
  ///
  /// Validates credentials and routes based on role:
  /// - Worker → Worker Home
  /// - Admin/Supervisor → Admin Home
  Future<void> login() async {
    if (!isValid) {
      errorMessage.value = 'Please enter username and password';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _authApiService.login(
        username: username.value,
        password: password.value,
      );

      final userData = response['user'] as Map<String, dynamic>;
      final workerData = response['worker'] as Map<String, dynamic>?;
      final token = response['token'] as String?;

      // Store auth token and set it on the API client
      if (token != null) {
        await _storageService.setAuthToken(token);
        Get.find<ApiClient>().setAuthToken(token);
      }

      // Store user data
      await _storageService.setUserId(userData['id']?.toString() ?? '');
      await _storageService.setUsername(userData['username'] as String? ?? '');
      await _storageService.setUserRole(userData['role'] as String? ?? '');

      // Store worker data if available
      if (workerData != null) {
        await _storageService.setWorkerId(workerData['worker_id'] as String? ?? '');
        await _storageService.setWorkerName(workerData['name'] as String? ?? '');
      }

      // F5 — register this device for push (no-op for non-worker / unconfigured).
      if (Get.isRegistered<PushService>()) {
        Get.find<PushService>().syncToken();
      }

      // Route based on role
      final role = userData['role'] as String?;
      if (role == 'worker') {
        // Navigate to worker home
        Get.offAllNamed(AppRoutes.WORKER_HOME);
      } else {
        // Navigate to admin home
        Get.offAllNamed(AppRoutes.HOME);
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// Clear error message
  void clearError() {
    errorMessage.value = '';
  }

  @override
  void onClose() {
    isLoading.close();
    errorMessage.close();
    isPasswordVisible.close();
    username.close();
    password.close();
    super.onClose();
  }
}
