# Research: UI Screens Design Specification

**Feature**: 001-ui-screens
**Date**: 2026-02-04
**Purpose**: Technology decisions and best practices for Flutter industrial safety app UI implementation

## Technology Decisions

### 1. State Management: GetX

**Decision**: Use GetX for all state management

**Rationale**:
- Lightweight and fast reactive programming
- Built-in dependency injection
- No need for BuildContext context for state updates (simpler for widgets)
- Good for large apps with many screens
- Easy testing with mock injection

**Alternatives Considered**:
- **Provider**: Too much boilerplate for large apps
- **Riverpod**: Newer, smaller community than GetX
- **Bloc**: More boilerplate, steeper learning curve

**Implementation Notes**:
- Use `.obs` for reactive state variables
- Use `Get.put()` for dependency injection in bindings
- Use `GetView<T>` for screen widgets to access controllers
- Use `RxNotifier` for complex state logic

### 2. HTTP Client: Dio

**Decision**: Use Dio for REST API calls

**Rationale**:
- Feature-rich (interceptors, transformers, cancellation)
- Built-in timeout handling
- Easy request/response transformation
- Good mock support for testing
- FormData support for file uploads

**Alternatives Considered**:
- **http**: Too basic, missing interceptors and timeout features
- **GraphQL**: Not needed for this phase (REST is sufficient)

**Implementation Notes**:
- Configure 30-second default timeout
- Add retry interceptor with exponential backoff
- Use interceptors for auth token injection (future)
- Log requests in debug mode only

### 3. Realtime Communication: WebSocket

**Decision**: Use `web_socket_channel` package for real-time detection stream

**Rationale**:
- Flutter-standard package
- Bi-directional communication
- Stream-based API (compatible with GetX)
- Low overhead for high-frequency messages

**Alternatives Considered**:
- **Socket.IO Client**: Heavy dependency, not Flutter-native
- **gRPC**: Overkill for this use case
- **Polling**: Too inefficient for real-time detection

**Implementation Notes**:
- Use `StreamController` to broadcast detection results
- Implement automatic reconnection with backoff
- Cache last known state for offline scenarios
- Use separate channel for camera control commands

### 4. Camera: camera Package

**Decision**: Use official `camera` package for real-time monitoring

**Rationale**:
- Official Flutter package
- Platform-specific optimizations
- Stream-based image rendering
- Good Android/iOS parity

**Alternatives Considered**:
- **image_picker**: Only for static images (used for upload screen)
- **flutter_webrtc**: Overkill, not needed for this use case

**Implementation Notes**:
- Target minimum 15fps for usable detection
- Use CameraController lifecycle properly
- Handle permission requests gracefully
- Provide fallback for "virtual camera" (video file) for demo

### 5. Local Storage: shared_preferences + Hive

**Decision**: Hybrid approach - shared_preferences for settings, Hive for cached data

**Rationale**:
- **shared_preferences**: Simple key-value for settings (theme, alerts, language)
- **Hive**: Fast NoSQL database for cached reports and worker lists

**Alternatives Considered**:
- **sqflite**: Too complex for simple caching needs
- **drift**: Overkill, adds unnecessary complexity

**Implementation Notes**:
- Settings stored in shared_preferences with default values
- Hive used for offline report data (sync when online)
- Clear cache on logout for privacy

### 6. Image Upload: image_picker

**Decision**: Use `image_picker` for gallery/camera selection

**Rationale**:
- Most popular Flutter image picker
- Cross-platform (iOS/Android)
- Handles permission requests
- Returns File object ready for upload

**Implementation Notes**:
- Compress images before upload (reduce bandwidth)
- Show progress indicator during upload
- Cache upload result locally

## Best Practices

### Flutter Project Structure

Based on Clean Architecture principles:

```
lib/
├── core/           # Shared, framework-agnostic code
├── data/           # Data models, repositories, services
├── domain/         # Business entities and use cases
├── presentation/   # UI layer (controllers, screens, widgets)
└── routes/         # Navigation configuration
```

**Key Practices**:
- One class per file
- Barrel exports (index files) for cleaner imports
- Feature-based organization for large features
- Absolute imports using package:

### GetX Patterns

**Controller Pattern**:
```dart
class HomeController extends GetxController {
  // Reactive state
  final isLoading = false.obs;
  final systemStatus = Rx<SystemStatus>(SystemStatus.normal);

  // Dependency injection
  final ApiClient _api = Get.find();

  // Lifecycle
  @override
  void onInit() {
    super.onInit();
    fetchStatus();
  }
}
```

**Navigation Pattern**:
```dart
// Named routes
Get.toNamed(Routes.MONITORING);

// With arguments
Get.toNamed(Routes.WORKER_DETAILS, arguments: {'id': workerId});
```

### Widget Organization

**Reusable Widget Pattern**:
```dart
class AppCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;

  const AppCard({
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    super.key,
  });

  @staticmethod
  Widget fromData(CardData data) {
    return AppCard(
      title: data.title,
      value: data.value,
      icon: data.icon,
      iconColor: data.color,
    );
  }
}
```

### Dark Theme Implementation

Based on spec color palette:

```dart
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  cardColor: AppColors.cardBackground,
  textTheme: TextTheme(
    bodyLarge: AppTextStyles.body,
    headlineMedium: AppTextStyles.heading,
  ),
);
```

### Testing Strategy

**Unit Tests**: Controllers and business logic
- Mock repositories using Mockito
- Test state changes
- Test error handling

**Widget Tests**: Individual widgets
- Test with mock data
- Verify correct rendering
- Test user interactions

**Integration Tests**: Full user flows
- Navigate through screens
- Test form submissions
- Verify navigation flow

## Architecture Patterns

### Repository Pattern

Abstract data source behind repository interface:

```dart
abstract class WorkerRepository {
  Future<List<Worker>> getWorkers();
  Future<Worker?> getWorker(String id);
  Future<void> addWorker(Worker worker);
}

class WorkerRepositoryImpl implements WorkerRepository {
  final WorkerApi _api;
  final WorkerCache _cache;

  WorkerRepositoryImpl(this._api, this._cache);

  @override
  Future<List<Worker>> getWorkers() async {
    try {
      return await _api.fetchWorkers();
    } catch (e) {
      return await _cache.getCachedWorkers();
    }
  }
}
```

### Service Layer Pattern

API services handle HTTP specifics:

```dart
class WorkerApi {
  final Dio _dio;

  Future<List<Worker>> fetchWorkers() async {
    final response = await _dio.get('/workers');
    return (response.data as List)
        .map((json) => Worker.fromJson(json))
        .toList();
  }
}
```

### WebSocket Stream Pattern

Real-time detection as reactive stream:

```dart
class DetectionStreamService extends GetxService {
  final WebSocketChannel _channel;
  final _detectionController = StreamController<DetectionResult>.broadcast();

  Stream<DetectionResult> get detections => _detectionController.stream;

  void startStream(String cameraId) {
    _channel = WebSocketChannel.connect(
      Uri.parse('$wsBaseUrl/detection/$cameraId'),
    );
    _channel.stream.listen((data) {
      final result = DetectionResult.fromJson(jsonDecode(data));
      _detectionController.add(result);
    });
  }
}
```

## Responsive Design Approach

### Breakpoint Strategy

```dart
class ScreenBreakpoints {
  static const double small = 375;   // Mobile portrait
  static const double medium = 768;  // Tablet portrait / Mobile landscape
  static const double large = 1024;  // Tablet landscape
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext, BoxConstraints) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: builder);
  }
}
```

### Adaptive Widget Pattern

```dart
class DashboardGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: width > 600 ? 3 : 2,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) => DashboardCard(index: index),
    );
  }
}
```

## Performance Considerations

### Image Optimization
- Compress images before upload (max 1MB)
- Use cached network images for remote URLs
- Lazy load lists with pagination

### Stream Optimization
- Debounce rapid state updates (max 10 updates/second)
- Use RxDistinct to avoid duplicate renders
- Cancel streams on widget disposal

### Memory Management
- Dispose controllers properly
- Use const constructors where possible
- Avoid large object trees in single rebuild

## Security Considerations (Future)

### When Backend is Integrated
- Use HTTPS for all API calls
- Implement certificate pinning
- Store auth tokens securely (flutter_secure_storage)
- Validate all inputs on both client and server
- Implement rate limiting for API calls

## Summary

| Technology | Choice | Version |
|------------|--------|---------|
| State Management | GetX | ^4.6.6 |
| HTTP Client | Dio | ^5.4.0 |
| WebSocket | web_socket_channel | ^2.4.0 |
| Camera | camera | ^0.10.5+7 |
| Image Picker | image_picker | ^1.0.7 |
| Local Settings | shared_preferences | ^2.2.2 |
| Local Cache | Hive | ^2.2.3 |
| Icons | flutter_svg | ^2.0.9 |
| Network Check | connectivity_plus | ^5.0.2 |
| Testing | flutter_test, mockito | ^5.4.4 |

All decisions align with the project constitution and support the defined architecture patterns.
