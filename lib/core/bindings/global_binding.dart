import 'package:get/get.dart';
import 'package:safesight/core/constants/api_constants.dart';
import '../../data/services/api/api_client.dart';
import '../../data/services/api/detection_api_service.dart';
import '../../data/services/api/auth_api_service.dart';
import '../../presentation/controllers/monitoring_controller.dart';
import '../../presentation/controllers/upload_controller.dart';
import '../../presentation/controllers/worker_controller.dart';
import '../../presentation/controllers/reports_controller.dart';
import '../../presentation/controllers/alert_config_controller.dart';
import '../../presentation/controllers/settings_controller.dart';
import '../../presentation/controllers/splash_controller.dart';

/// Global binding for initializing all controllers and services.
/// This should be called once when the app starts.
class GlobalBinding extends Bindings {
  @override
  void dependencies() {
    // Core services - initialize first
    // Use fenix: true to recreate if disposed
    Get.lazyPut<ApiClient>(() => ApiClient.create(
          baseUrl: ApiConstants.baseUrl,
          timeout: ApiConstants.requestTimeout,
        ), fenix: true);

    // API services
    Get.lazyPut<DetectionApiService>(() => DetectionApiService(), fenix: true);
    Get.lazyPut<AuthApiService>(() => AuthApiService(), fenix: true);

    // Controllers
    Get.lazyPut<SplashController>(() => SplashController());
    Get.lazyPut<MonitoringController>(() => MonitoringController());
    // Use fenix: true to recreate controller if it was disposed
    Get.lazyPut<UploadController>(() => UploadController(), fenix: true);
    Get.lazyPut<WorkerController>(() => WorkerController());
    Get.lazyPut<ReportsController>(() => ReportsController());
    Get.lazyPut<AlertConfigController>(() => AlertConfigController());
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}
