# Quickstart: UI Screens Implementation

**Feature**: 001-ui-screens
**Date**: 2026-02-04
**Purpose**: Get started with implementing the UI screens for the industrial safety monitoring app

---

## Prerequisites

Before starting implementation, ensure you have:

- Flutter SDK 3.16+ installed
- Dart 3.0+ installed
- Android Studio / Xcode for mobile development
- A code editor (VS Code with Flutter extension recommended)
- Basic understanding of GetX state management

---

## Project Setup

### 1. Initialize Flutter Project

```bash
# Create new Flutter project
flutter create safesight_app

# Navigate to project
cd safesight_app

# Verify installation
flutter doctor
```

### 2. Add Dependencies

Update `pubspec.yaml` with required dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  get: ^4.6.6

  # HTTP & Networking
  dio: ^5.4.0
  web_socket_channel: ^2.4.0
  connectivity_plus: ^5.0.2

  # Camera & Images
  camera: ^0.10.5+7
  image_picker: ^1.0.7

  # Local Storage
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # UI Components
  flutter_svg: ^2.0.9

  # Utilities
  equatable: ^2.0.5
  intl: ^0.18.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  mockito: ^5.4.4
  build_runner: ^2.4.6
```

Run `flutter pub get` to install dependencies.

### 3. Create Project Structure

```bash
# Create directories
mkdir -p lib/core/{constants,theme,utils}
mkdir -p lib/data/{models,repositories,services/{api,websocket}}
mkdir -p lib/domain/{entities,usecases}
mkdir -p lib/presentation/{controllers,screens,widgets/{common,ppe_indicators}}
mkdir -p lib/routes
mkdir -p assets/{images,icons}
```

### 4. Configure Assets

Update `pubspec.yaml` to include assets:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
```

---

## Core Setup (Do First)

### Step 1: Define Colors

Create `lib/core/constants/app_colors.dart`:

```dart
import 'package:flutter/material.dart';

class AppColors {
  // Background colors
  static const Color background = Color(0xFF121212);
  static const Color cardBackground = Color(0xFF1E1E1E);
  static const Color splashBackground = Color(0xFF0A1929);

  // Primary colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);

  // Semantic colors
  static const Color success = Color(0xFF4CAF50);     // Green - compliant
  static const Color warning = Color(0xFFFFC107);     // Yellow - partial
  static const Color error = Color(0xFFF44336);       // Red - non-compliant
  static const Color critical = Color(0xFFD32F2F);    // Dark red

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textDisabled = Color(0xFF757575);

  // Status overlay colors (with transparency)
  static final Color compliantOverlay = success.withOpacity(0.3);
  static final Color partialOverlay = warning.withOpacity(0.3);
  static final Color violationOverlay = error.withOpacity(0.3);
}
```

### Step 2: Define Theme

Create `lib/core/theme/app_theme.dart`:

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

final ThemeData appTheme = ThemeData.dark().copyWith(
  brightness: Brightness.dark,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  cardColor: AppColors.cardBackground,

  // App Bar Theme
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.cardBackground,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
  ),

  // Text Theme
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: AppColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: AppColors.textSecondary,
    ),
  ),

  // Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),

  // Input Decoration Theme
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.cardBackground,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
    ),
  ),
);
```

### Step 3: Setup Routes

Create `lib/routes/app_routes.dart`:

```dart
abstract class AppRoutes {
  static const SPLASH = '/';
  static const HOME = '/home';
  static const MONITORING = '/monitoring';
  static const ADD_WORKER = '/worker/add';
  static const UPLOAD_DETECTION = '/upload';
  static const REPORTS = '/reports';
  static const ALERT_CONFIG = '/alerts/config';
  static const INSTRUCTIONS = '/instructions';
  static const SETTINGS = '/settings';
}
```

Create `lib/routes/route_generator.dart`:

```dart
import 'package:get/get.dart';
import 'app_routes.dart';

class AppRouteGenerator {
  static GetPageRoute unknownRoute() => GetPage(
    name: '/unknown',
    page: () => const UnknownScreen(),
  );

  static List<GetPage> routes() => [
    // Add routes as screens are implemented
  ];
}
```

### Step 4: Setup Main App

Update `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'routes/route_generator.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SafeSightApp());
}

class SafeSightApp extends StatelessWidget {
  const SafeSightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SafeSight - Industrial Safety Monitoring',
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.SPLASH,
      getPages: AppRouteGenerator.routes(),
      unknownRoute: AppRouteGenerator.unknownRoute(),
      home: const SplashScreen(),
    );
  }
}
```

---

## Implementation Order

### Phase 1: Foundation (P0)

Implement in this order:

1. **Splash Screen** - App branding and initialization
2. **Home Screen** - Main dashboard with navigation
3. **Bottom Navigation** - Common navigation component

### Phase 2: Core Features (P1)

4. **Real-Time Monitoring** - Camera feed with detection overlays
5. **Add Worker Form** - Worker registration

### Phase 3: Secondary Features (P2)

6. **Image Upload Detection** - Manual PPE analysis
7. **Reports Screen** - Analytics dashboard
8. **Alert Configuration** - Notification settings

### Phase 4: Help & Settings (P3)

9. **App Usage Instructions** - Help and tutorials
10. **Settings Screen** - Profile and preferences

---

## Implementing a Screen

### Template Pattern

Each screen follows this structure:

```dart
// 1. Create the controller
// lib/presentation/controllers/screen_controller.dart

class ScreenController extends GetxController {
  // Reactive state
  final isLoading = false.obs;

  // Dependencies
  final ApiClient _api = Get.find();

  @override
  void onInit() {
    super.onInit();
    // Initialize data
  }

  @override
  void onClose() {
    // Clean up
    super.onClose();
  }

  // Actions
  Future<void> loadData() async {
    isLoading.value = true;
    try {
      // Fetch data
    } finally {
      isLoading.value = false;
    }
  }
}

// 2. Create the screen
// lib/presentation/screens/screen_screen.dart

class ScreenScreen extends GetView<ScreenController> {
  const ScreenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Screen Title')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildContent();
      }),
    );
  }

  Widget _buildContent() {
    return Container();
  }
}

// 3. Add to routes
// lib/routes/route_generator.dart

GetPage(
  name: AppRoutes.SCREEN,
  page: () => const ScreenScreen(),
  binding: BindingsBuilder(() {
    Get.lazyPut<ScreenController>(() => ScreenController());
  }),
),
```

---

## Common Widget Patterns

### Status Badge

```dart
class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;

  const StatusBadge({
    required this.text,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }
}
```

### Summary Card

```dart
class SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;
  final VoidCallback? onTap;

  const SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.iconColor,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBackground,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Mock Data for Development

Create `lib/data/mock/mock_data.dart`:

```dart
class MockData {
  static List<Map<String, dynamic>> getWorkers() => [
    {
      'id': '12345678',
      'fullName': 'John Doe',
      'department': 'Production',
      'jobTitle': 'Machine Operator',
      'requiredPpe': ['hardHat', 'safetyGlasses', 'vest', 'steelToedBoots'],
      'violationCount': 3,
    },
    // ... more mock workers
  ];

  static Map<String, dynamic> getSystemStatus() => {
    'status': 'normal',
    'activeCameras': 4,
    'lastUpdate': DateTime.now().toIso8601String(),
    'message': 'All systems normal',
  };
}
```

---

## Running the App

```bash
# Run on connected device/emulator
flutter run

# Run with specific device
flutter devices
flutter run -d <device-id>

# Run release mode
flutter run --release
```

---

## Testing

```bash
# Run all tests
flutter test

# Run widget tests
flutter test test/widget/

# Run integration tests
flutter test integration_test/

# Generate coverage
flutter test --coverage
```

---

## Next Steps

1. Implement screens in the order listed above
2. Create reusable widgets as you identify patterns
3. Add models matching the data-model.md specification
4. Create mock API services using the contract definitions
5. Test each screen independently before moving to the next

For detailed specifications, see:
- [Data Model](data-model.md) - Entity definitions
- [API Contracts](contracts/) - API endpoint definitions
- [Research](research.md) - Technology decisions

---

## Troubleshooting

### GetX Route Not Found

Ensure routes are added to `AppRouteGenerator.routes()` and screen bindings are properly defined.

### Mock Data Not Loading

Check that `Get.put()` or `Get.lazyPut()` is called for the controller before navigation.

### Dark Theme Not Applied

Verify `appTheme` is set in `GetMaterialApp` and `AppColors.background` is used for scaffold backgrounds.

---

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [GetX Documentation](https://github.com/jonataslaw/getx)
- [Dart Language Guide](https://dart.dev/guides)
