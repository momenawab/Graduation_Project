import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'core/bindings/global_binding.dart';
import 'routes/app_routes.dart';
import 'routes/route_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SafeSightApp());
}

class SafeSightApp extends StatelessWidget {
  const SafeSightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SafeSight',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      initialRoute: AppRoutes.SPLASH,
      getPages: AppRouteGenerator.routes(),
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      initialBinding: GlobalBinding(), // Initialize all controllers
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
    );
  }
}
