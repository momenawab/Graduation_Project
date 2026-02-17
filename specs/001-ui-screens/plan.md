# Implementation Plan: UI Screens Design Specification

**Branch**: `001-ui-screens` | **Date**: 2026-02-04 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-ui-screens/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

This feature implements the UI layer for an AI-powered industrial safety monitoring mobile application. The app provides real-time PPE (Personal Protective Equipment) detection, worker management, safety reports, and alert configuration. This specification phase defines 9 screens with complete visual design, navigation flow, and reusable components. The implementation will follow Clean Architecture with GetX state management, focusing on UI structure and design clarity while remaining API-ready for future backend integration.

## Technical Context

**Language/Version**: Dart 3.0+ (Flutter SDK 3.16+)
**Primary Dependencies**:
  - get: ^4.6.6 (state management)
  - dio: ^5.4.0 (HTTP client)
  - web_socket_channel: ^2.4.0 (WebSocket for realtime)
  - flutter_svg: ^2.0.9 (SVG icons)
  - image_picker: ^1.0.7 (camera/gallery access)
  - camera: ^0.10.5+7 (real-time camera feed)
  - shared_preferences: ^2.2.2 (local settings cache)
  - connectivity_plus: ^5.0.2 (network status)

**Storage**:
  - Local: shared_preferences (settings cache), Hive (offline data)
  - Remote: REST API (to be defined), WebSocket (realtime detection stream)

**Testing**:
  - flutter_test (widget and unit tests)
  - mockito: ^5.4.4 (mocking)
  - integration_test (end-to-end flows)

**Target Platform**: iOS 13+, Android 8.0+ (API 21+)

**Project Type**: mobile (Flutter cross-platform)

**Performance Goals**:
  - UI render: 60fps for all animations
  - Detection overlay update: < 100ms from WebSocket message to display
  - Screen navigation: < 50ms perceived delay
  - Image upload: Progress indicator within 100ms of selection

**Constraints**:
  - Camera feed MUST run at minimum 15fps for usable detection
  - UI MUST remain responsive during WebSocket streaming
  - Offline mode for settings and cached data only
  - App size < 100MB (excluding cached images)

**Scale/Scope**:
  - 9 screens total
  - 8 reusable UI components
  - Target: 100-500 concurrent users
  - ~10-15 API endpoints (when backend is implemented)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Principle I: Clean Architecture
- **Status**: PASS
- **Compliance**: UI layer (widgets), Controller layer (GetX), Service layer (API/WebSocket), Model layer (entities) are clearly separated in the defined project structure
- **Verification**: Each screen will have dedicated controller, models, and services in separate directories

### Principle II: API-First Design
- **Status**: PASS (with deferral)
- **Compliance**: All screens are designed API-ready. Contracts will be defined in this phase for future backend implementation
- **Note**: Actual API endpoints will be stubs/mocks for UI implementation phase. Real backend integration is a separate feature

### Principle III: Realtime-Ready Architecture
- **Status**: PASS
- **Compliance**: Real-time monitoring screen uses WebSocket channel pattern. Detection overlays use reactive state (GetX .obs) for frame-by-frame updates
- **Verification**: Camera feed with overlay testing in integration tests

### Principle IV: Visual Clarity & Industrial Standards
- **Status**: PASS
- **Compliance**: Dark theme with semantic color coding (green/red/yellow/blue). High contrast text. Minimal animations. Status icons defined
- **Verification**: Visual design system with specific color palette, typography, and spacing defined in spec

### Principle V: Role-Based Access Control
- **Status**: DEFERRED
- **Compliance**: Role separation (Admin vs User) is defined in constitution but not implemented in this UI-only phase
- **Justification**: This phase focuses on UI structure. Role enforcement will be implemented when authentication/authorization backend is integrated

**Constitution Check Result**: PASS (1 item deferred with justification)

## Project Structure

### Documentation (this feature)

```text
specs/001-ui-screens/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── checklists/          # Quality checklists
    └── requirements.md  # Spec validation checklist
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart      # Color palette from spec
│   │   ├── app_strings.dart     # String constants
│   │   └── app_assets.dart      # Asset paths
│   ├── theme/
│   │   ├── app_theme.dart       # Main theme configuration
│   │   └── text_styles.dart     # Typography definitions
│   └── utils/
│       ├── validators.dart      # Input validation helpers
│       └── formatters.dart      # Data formatting utilities
├── data/
│   ├── models/
│   │   ├── worker.dart          # Worker profile model
│   │   ├── ppe_item.dart        # PPE item model
│   │   ├── detection_result.dart # Detection result model
│   │   ├── alert_config.dart    # Alert configuration model
│   │   └── report_data.dart     # Reports/analytics model
│   ├── repositories/
│   │   ├── worker_repository.dart      # Worker data access
│   │   ├── alert_repository.dart      # Alert config access
│   │   └── report_repository.dart     # Reports data access
│   └── services/
│       ├── api/
│       │   ├── api_client.dart        # Dio HTTP client wrapper
│       │   ├── worker_api.dart        # Worker endpoints (stubs)
│       │   ├── report_api.dart        # Report endpoints (stubs)
│       │   └── alert_api.dart         # Alert endpoints (stubs)
│       └── websocket/
│           ├── detection_stream.dart  # WebSocket for real-time detection
│           └── stream_client.dart     # WebSocket channel wrapper
├── domain/
│   ├── entities/
│   │   ├── worker_entity.dart    # Core worker entity
│   │   └── ppe_status_entity.dart # PPE status entity
│   └── usecases/
│       ├── add_worker.dart       # Add worker use case
│       ├── upload_detection.dart # Image upload use case
│       └── fetch_reports.dart    # Fetch reports use case
├── presentation/
│   ├── controllers/
│   │   ├── home_controller.dart          # Home dashboard controller
│   │   ├── monitoring_controller.dart    # Real-time monitoring controller
│   │   ├── worker_controller.dart        # Worker form controller
│   │   ├── upload_controller.dart        # Image upload controller
│   │   ├── reports_controller.dart       # Reports controller
│   │   ├── alert_config_controller.dart  # Alert configuration controller
│   │   ├── instructions_controller.dart  # App usage controller
│   │   └── settings_controller.dart      # Settings controller
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── home_screen.dart
│   │   ├── monitoring_screen.dart
│   │   ├── add_worker_screen.dart
│   │   ├── upload_detection_screen.dart
│   │   ├── reports_screen.dart
│   │   ├── alert_config_screen.dart
│   │   ├── instructions_screen.dart
│   │   └── settings_screen.dart
│   └── widgets/
│       ├── common/
│       │   ├── app_button.dart           # Standard button widget
│       │   ├── app_card.dart             # Summary card widget
│       │   ├── app_input.dart            # Text input widget
│       │   ├── status_badge.dart         # Status badge widget
│       │   ├── bottom_nav_bar.dart       # Bottom navigation
│       │   └── top_app_bar.dart          # Top header bar
│       └── ppe_indicators/
│           ├── ppe_status_widget.dart    # PPE status indicator
│           ├── detection_overlay.dart    # Bounding box overlay
│           ├── compliance_badge.dart     # Compliance score badge
│           └── alert_banner.dart         # Alert notification banner
└── routes/
    ├── app_routes.dart           # Route constants
    └── route_generator.dart      # GetX route generator

test/
├── unit/
│   ├── controllers/
│   ├── services/
│   └── utils/
├── widget/
│   └── widgets/
└── integration/
    └── flows/

assets/
├── images/
│   └── [app icons, illustrations]
└── icons/
    └── [SVG icon files]
```

**Structure Decision**: Mobile Flutter app using Clean Architecture. The structure follows the constitution-mandated separation with:
- `core/` for shared constants, theme, and utilities
- `data/` for models, repositories, and services (API/WebSocket)
- `domain/` for business entities and use cases
- `presentation/` for UI controllers, screens, and reusable widgets
- `routes/` for navigation configuration

This structure enables independent testing, easy mock substitution for API calls, and clear separation of concerns.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Clean Architecture | PASS | Fully compliant with defined structure |
| II. API-First Design | PASS | Contracts defined, stubs for UI phase |
| III. Realtime-Ready | PASS | WebSocket pattern for detection stream |
| IV. Visual Clarity | PASS | Design system with semantic colors |
| V. Role-Based Access | DEFERRED | UI designed for roles; enforcement deferred to backend integration phase |

No violations requiring justification. One item deferred (V. Role-Based Access Control) because this phase focuses on UI structure only. Authentication and authorization will be implemented when backend services are integrated.

