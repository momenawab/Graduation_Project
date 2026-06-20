import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_routes.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/monitoring_screen.dart';
import '../presentation/screens/video_test_screen.dart';
import '../presentation/screens/add_worker_screen.dart';
import '../presentation/screens/upload_detection_screen.dart';
import '../presentation/screens/reports_screen.dart';
import '../presentation/screens/alert_config_screen.dart';
import '../presentation/screens/instructions_screen.dart';
import '../presentation/screens/settings_screen.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/worker_home_screen.dart';
import '../presentation/screens/worker_notifications_screen.dart';
import '../presentation/screens/worker_violations_screen.dart';
import '../presentation/screens/coming_soon_screen.dart';
import '../presentation/screens/worker_monitor_screen.dart';
import '../presentation/screens/camera_management_screen.dart';
import '../presentation/screens/workers_list_screen.dart';
import '../presentation/screens/worker_details_screen.dart';
import '../presentation/screens/power_bi_report_screen.dart';
import '../presentation/screens/report_incident_screen.dart';

class AppRouteGenerator {
  static GetPage unknownRoute() =>
      GetPage(name: '/unknown', page: () => const _UnknownScreen());

  static List<GetPage> routes() => [
    // Splash screen
    GetPage(name: AppRoutes.SPLASH, page: () => const SplashScreen()),
    // Login screen (unified for admin and worker)
    GetPage(name: AppRoutes.LOGIN, page: () => const LoginScreen()),
    // Home screen (admin)
    GetPage(name: AppRoutes.HOME, page: () => const HomeScreen()),
    // Monitoring screen
    GetPage(name: AppRoutes.MONITORING, page: () => const MonitoringScreen()),
    // Video Test screen
    GetPage(name: AppRoutes.VIDEO_TEST, page: () => const VideoTestScreen()),
    // Add Worker screen
    GetPage(name: AppRoutes.ADD_WORKER, page: () => const AddWorkerScreen()),
    // Upload Detection screen
    GetPage(name: AppRoutes.UPLOAD_DETECTION, page: () => const UploadDetectionScreen()),
    // Reports screen
    GetPage(name: AppRoutes.REPORTS, page: () => const ReportsScreen()),
    // Alert Config screen
    GetPage(name: AppRoutes.ALERT_CONFIG, page: () => const AlertConfigScreen()),
    // Instructions screen
    GetPage(name: AppRoutes.INSTRUCTIONS, page: () => const InstructionsScreen()),
    // Worker Monitor screen
    GetPage(name: AppRoutes.WORKER_MONITOR, page: () => const WorkerMonitorScreen()),
    // Camera Management screen
    GetPage(name: AppRoutes.CAMERA_MANAGEMENT, page: () => const CameraManagementScreen()),
    // Settings screen
    GetPage(name: AppRoutes.SETTINGS, page: () => const SettingsScreen()),
    // Coming Soon placeholder
    GetPage(
      name: AppRoutes.COMING_SOON,
      page: () => ComingSoonScreen(
        icon: Get.parameters['icon'] == 'monitoring'
            ? Icons.videocam
            : Get.parameters['icon'] == 'thresholds'
                ? Icons.warning
                : Icons.build,
        featureName: Get.parameters['title'] ?? 'Feature',
        description: Get.parameters['description'],
      ),
    ),
    // Power BI embedded dashboard
    GetPage(name: AppRoutes.POWER_BI, page: () => const PowerBiReportScreen()),
    // Workers List screen
    GetPage(name: AppRoutes.WORKERS_LIST, page: () => const WorkersListScreen()),
    // Worker Details screen
    GetPage(
      name: AppRoutes.WORKER_DETAILS,
      page: () => WorkerDetailsScreen(workerId: Get.parameters['id'] ?? ''),
    ),
    // Worker screens (worker role)
    GetPage(name: AppRoutes.WORKER_HOME, page: () => const WorkerHomeScreen()),
    GetPage(name: AppRoutes.WORKER_NOTIFICATIONS, page: () => const WorkerNotificationsScreen()),
    GetPage(name: AppRoutes.WORKER_VIOLATIONS, page: () => const WorkerViolationsScreen()),
    // Report Incident (F15)
    GetPage(name: AppRoutes.REPORT_INCIDENT, page: () => const ReportIncidentScreen()),
  ];
}

class _UnknownScreen extends StatelessWidget {
  const _UnknownScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Unknown Screen')));
  }
}
