import 'package:get/get.dart';
import 'package:safesight/core/constants/api_constants.dart';
import '../../data/services/api/api_client.dart';
import '../../data/services/api/detection_api_service.dart';
import '../../data/services/api/auth_api_service.dart';
import '../../data/services/api/worker_api.dart';
import '../../data/services/api/camera_api.dart';
import '../../data/services/websocket/notification_stream.dart';
import '../../presentation/controllers/monitoring_controller.dart';
import '../../presentation/controllers/video_test_controller.dart';
import '../../presentation/controllers/upload_controller.dart';
import '../../presentation/controllers/worker_controller.dart';
import '../../presentation/controllers/reports_controller.dart';
import '../../presentation/controllers/alert_config_controller.dart';
import '../../presentation/controllers/settings_controller.dart';
import '../../presentation/controllers/splash_controller.dart';
import '../../presentation/controllers/login_controller.dart';
import '../../presentation/controllers/worker_home_controller.dart';

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
    Get.lazyPut<WorkerApi>(() => WorkerApi(apiClient: Get.find<ApiClient>()), fenix: true);
    Get.lazyPut<CameraApi>(() => CameraApi(apiClient: Get.find<ApiClient>()), fenix: true);

    // WebSocket services
    Get.lazyPut<NotificationStream>(() => NotificationStream(), fenix: true);

    // Controllers
    Get.lazyPut<SplashController>(() => SplashController());
    Get.lazyPut<LoginController>(() => LoginController(), fenix: true);
    Get.lazyPut<MonitoringController>(() => MonitoringController(), fenix: true);
    Get.lazyPut<VideoTestController>(() => VideoTestController(), fenix: true);
    // Use fenix: true to recreate controller if it was disposed
    Get.lazyPut<UploadController>(() => UploadController(), fenix: true);
    Get.lazyPut<WorkerController>(() => WorkerController(), fenix: true);
    Get.lazyPut<ReportsController>(() => ReportsController(), fenix: true);
    Get.lazyPut<AlertConfigController>(() => AlertConfigController(), fenix: true);
    Get.lazyPut<SettingsController>(() => SettingsController(), fenix: true);
    Get.lazyPut<WorkerHomeController>(() => WorkerHomeController(), fenix: true);
  }
}
