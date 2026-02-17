import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

/// Controller for the splash screen.
class SplashController extends GetxController {
  /// Observable for loading state
  final RxBool isLoading = true.obs;

  /// Observable for error message
  final RxString errorMessage = ''.obs;

  /// Observable for initialization complete
  final RxBool isInitialized = false.obs;

  /// Initializes the splash screen and navigates to home.
  Future<void> initialize() async {
    try {
      // Simulate initialization delay
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Add actual initialization logic here:
      // - Load user preferences
      // - Check authentication status
      // - Load cached data
      // - Initialize services

      isLoading.value = false;
      isInitialized.value = true;

      // Navigate to home screen
      Get.offAllNamed(AppRoutes.HOME);
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
