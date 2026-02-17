import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../data/services/api/api_client.dart';
import '../../../data/services/storage_service.dart';

/// Controller for the splash screen.
class SplashController extends GetxController {
  /// Storage service - initialized on demand
  StorageService get _storageService => Get.find<StorageService>();

  /// Observable for loading state
  final RxBool isLoading = true.obs;

  /// Observable for error message
  final RxString errorMessage = ''.obs;

  /// Observable for initialization complete
  final RxBool isInitialized = false.obs;

  /// Initializes the splash screen and navigates based on auth state.
  Future<void> initialize() async {
    try {
      // Initialize StorageService first
      if (!Get.isRegistered<StorageService>()) {
        await Get.putAsync<StorageService>(
          () => StorageService.getInstance(),
          permanent: true,
        );
      }

      // Simulate initialization delay
      await Future.delayed(const Duration(seconds: 2));

      isLoading.value = false;
      isInitialized.value = true;

      // Check if user is logged in
      if (_storageService.isLoggedIn) {
        // Restore auth token on the API client
        final token = _storageService.authToken;
        if (token != null) {
          Get.find<ApiClient>().setAuthToken(token);
        }

        // Route based on user role
        final role = _storageService.userRole;

        if (role == 'worker') {
          // Worker -> Worker Home
          Get.offAllNamed(AppRoutes.WORKER_HOME);
        } else {
          // Admin/Supervisor/Operator/Viewer -> Admin Home
          Get.offAllNamed(AppRoutes.HOME);
        }
      } else {
        // Not logged in -> Login screen
        Get.offAllNamed(AppRoutes.LOGIN);
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
    }
  }

  /// Retries initialization after an error.
  void retry() {
    errorMessage.value = '';
    isLoading.value = true;
    initialize();
  }

  @override
  void onClose() {
    super.onClose();
    isLoading.close();
    errorMessage.close();
    isInitialized.close();
  }
}
