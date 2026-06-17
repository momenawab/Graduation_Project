import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'core/bindings/global_binding.dart';
import 'core/localization/app_translations.dart';
import 'data/services/push_service.dart';
import 'data/services/storage_service.dart';
import 'data/services/offline_cache.dart';
import 'routes/app_routes.dart';
import 'routes/route_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Init storage early so we can read the saved language for the initial locale.
  await Get.putAsync<StorageService>(() => StorageService.getInstance(),
      permanent: true);
  // F11 — offline cache (Hive).
  await Get.putAsync<OfflineCache>(() => OfflineCache().init(), permanent: true);
  // F5 — initialise push (no-op if Firebase isn't configured).
  await Get.putAsync(() => PushService().init(), permanent: true);
  runApp(const SafeSightApp());
}

class SafeSightApp extends StatelessWidget {
  const SafeSightApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Get.find<StorageService>().userLanguage; // 'en' | 'ar'
    return GetMaterialApp(
      title: 'SafeSight',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      // F12 — localization (English + Arabic). Arabic renders RTL automatically.
      translations: AppTranslations(),
      locale: Locale(lang),
      fallbackLocale: const Locale('en'),
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
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
