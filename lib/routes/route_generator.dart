import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_routes.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/monitoring_screen.dart';
import '../presentation/screens/add_worker_screen.dart';
import '../presentation/screens/upload_detection_screen.dart';
import '../presentation/screens/reports_screen.dart';
import '../presentation/screens/alert_config_screen.dart';
import '../presentation/screens/instructions_screen.dart';
import '../presentation/screens/settings_screen.dart';

class AppRouteGenerator {
  static GetPage unknownRoute() =>
      GetPage(name: '/unknown', page: () => const _UnknownScreen());

  static List<GetPage> routes() => [
    // Splash screen
    GetPage(name: AppRoutes.SPLASH, page: () => const SplashScreen()),
    // Home screen
    GetPage(name: AppRoutes.HOME, page: () => const HomeScreen()),
    // Monitoring screen
    GetPage(name: AppRoutes.MONITORING, page: () => const MonitoringScreen()),
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
    // Settings screen
    GetPage(name: AppRoutes.SETTINGS, page: () => const SettingsScreen()),
  ];
}

class _UnknownScreen extends StatelessWidget {
  const _UnknownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Unknown Screen')));
  }
}
