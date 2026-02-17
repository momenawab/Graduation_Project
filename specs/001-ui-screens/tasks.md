# Tasks: UI Screens Design Specification

**Input**: Design documents from `/specs/001-ui-screens/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/
**Feature**: UI Screens Design Specification for SafeSight - Industrial Safety Monitoring App
**Tech Stack**: Dart 3.0+ (Flutter SDK 3.16+), GetX state management, Dio HTTP client, WebSocket

**Tests**: Tests are OPTIONAL for this UI-only phase. No test tasks included unless explicitly requested.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Path Conventions

- **Mobile Flutter**: `lib/` at repository root, with Clean Architecture (core/, data/, domain/, presentation/)
- Tests: `test/unit/`, `test/widget/`, `test/integration/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Flutter project initialization and Clean Architecture structure

- [X] T001 Initialize Flutter project with GetX, Dio, WebSocket, camera, image_picker dependencies in lib/pubspec.yaml
- [X] T002 [P] Create Clean Architecture directory structure: lib/core/{constants,theme,utils}, lib/data/{models,repositories,services}, lib/domain/{entities,usecases}, lib/presentation/{controllers,screens,widgets}, lib/routes/
- [X] T003 [P] Configure app colors in lib/core/constants/app_colors.dart with dark theme palette (#121212 background, #2196F3 primary, #4CAF50 success, #F44336 error, #FFC107 warning)
- [X] T004 [P] Create app strings resource file in lib/core/constants/app_strings.dart (app name "SafeSight", navigation titles, button labels, error messages)
- [X] T005 [P] Create dark theme configuration in lib/core/theme/app_theme.dart (textTheme, cardTheme, elevatedButtonTheme, inputDecorationTheme)
- [X] T006 [P] Create text styles definitions in lib/core/theme/text_styles.dart (headlineLarge 28px, headlineMedium 24px, bodyLarge 16px, bodyMedium 14px, caption 12px)
- [X] T007 [P] Create input validators in lib/core/utils/validators.dart (validateWorkerId 8 digits, validateFullName 2-100 chars, validateNonEmpty)
- [X] T008 [P] Create data formatters in lib/core/utils/formatters.dart (formatDate, formatCompliancePercentage, formatDuration)
- [X] T009 [P] Create route constants in lib/routes/app_routes.dart (SPLASH, HOME, MONITORING, ADD_WORKER, UPLOAD_DETECTION, REPORTS, ALERT_CONFIG, INSTRUCTIONS, SETTINGS)
- [X] T010 Create route generator in lib/routes/route_generator.dart with GetPage bindings for dependency injection

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core models, reusable widgets, and API stub infrastructure that ALL user stories depend on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

### Core Models (Data Layer)

- [X] T011 [P] Create Worker model in lib/data/models/worker.dart with id, fullName, department, jobTitle, requiredPpe, createdAt, violationCount (with fromJson/toJson, copyWith, equatable)
- [X] T012 [P] Create PPEType enum in lib/data/models/ppe_item.dart (hardHat, safetyGlasses, vest, gloves, steelToedBoots, earProtection)
- [X] T013 [P] Create PPEStatus enum in lib/data/models/ppe_item.dart (compliant, missing, notSuitable, notRequired)
- [X] T014 [P] Create PPEItem model in lib/data/models/ppe_item.dart with type, status, lastDetected (with fromJson/toJson, copyWith, equatable)
- [X] T015 [P] Create DetectionResult model in lib/data/models/detection_result.dart with frameId, detected, compliant, nonCompliant, detections list
- [X] T016 [P] Create PersonDetection nested model in lib/data/models/detection_result.dart with workerId, boundingBox, ppeStatus list, overallStatus, confidence
- [X] T017 [P] Create ComplianceStatus enum in lib/data/models/detection_result.dart (compliant, partial, nonCompliant)
- [X] T018 [P] Create BoundingBox model in lib/data/models/detection_result.dart with x, y, width, height (0-1 relative coordinates)
- [X] T019 [P] Create AlertConfig model in lib/data/models/alert_config.dart with alertType, enabled, deliveryMode, priority
- [X] T020 [P] Create AlertType enum in lib/data/models/alert_config.dart (ppeCompliance, proxWarning, stealthMode, zoneIncursion, safetyMetrics, systemStatus)
- [X] T021 [P] Create DeliveryMode enum in lib/data/models/alert_config.dart (audio, haptic, dual)
- [X] T022 [P] Create AlertPriority enum in lib/data/models/alert_config.dart (critical, normal)
- [X] T023 [P] Create ReportData model in lib/data/models/report_data.dart with incidents, incidentsTrend, compliance, complianceTrend, dateRange, chartData, lastUpdate
- [X] T024 [P] Create SystemStatus model in lib/data/models/system_status.dart with status (SystemHealth enum), activeCameras, lastUpdate, message
- [X] T025 [P] Create SystemHealth enum in lib/data/models/system_status.dart (normal, warning, critical, offline)
- [X] T026 [P] Create UserSettings model in lib/data/models/user_settings.dart with userId, fullName, title, employeeId, avatarUrl, language, appearance, hazardAlerts, safeZoneMonitoring, biometricAuth, isOnline
- [X] T027 [P] Create ThemeMode enum in lib/data/models/user_settings.dart (light, dark, system)
- [X] T028 [P] Create UploadDetectionResult model in lib/data/models/upload_result.dart with imageId, imageUrl, analysisStatus, complianceScore, ppeResults, analyzedAt
- [X] T029 [P] Create AnalysisStatus enum in lib/data/models/upload_result.dart (pending, analyzing, completed, failed)

### Mock API Services (Stubs)

- [X] T030 [P] Create Dio HTTP client wrapper in lib/data/services/api/api_client.dart with 30 second timeout, interceptors, error handling
- [X] T031 [P] Create WorkerApi stub in lib/data/services/api/worker_api.dart with getWorkers, getWorker, createWorker, updateWorker, deleteWorker, getDepartments, getJobTitles methods
- [X] T032 [P] Create ReportApi stub in lib/data/services/api/report_api.dart with getSummary, getChartData, getViolations, getWorkerReport, exportReport methods
- [X] T033 [P] Create AlertApi stub in lib/data/services/api/alert_api.dart with getConfig, updateConfig, getHistory, markAsRead, markAllAsRead, deleteAlert, testAlert methods
- [X] T034 [P] Create SettingsApi stub in lib/data/services/api/settings_api.dart with getSettings, updateSettings, getProfile, updateProfile, uploadAvatar, getLanguages, logout methods
- [X] T035 [ ] Create InstructionsApi stub in lib/data/services/api/instructions_api.dart with getCategories, getTutorials, getTutorial, getFaq, searchContent methods
- [X] T036 [P] Create DetectionStream WebSocket service in lib/data/services/websocket/detection_stream.dart with connection management, stream controller, reconnection logic
- [X] T037 [ ] Create StreamClient wrapper in lib/data/services/websocket/stream_client.dart for WebSocket channel management

### Repositories

- [X] T038 [P] Create WorkerRepository in lib/data/repositories/worker_repository.dart with WorkerApi dependency, caching with Hive
- [X] T039 [P] Create AlertRepository in lib/data/repositories/alert_repository.dart with AlertConfig dependency
- [X] T040 [P] Create ReportRepository in lib/data/repositories/report_repository.dart with ReportData dependency and Hive caching

### Reusable UI Widgets (Common)

- [X] T041 [P] Create AppButton widget in lib/presentation/widgets/common/app_button.dart with text, icon, loading state variants
- [X] T042 [P] Create AppCard widget in lib/presentation/widgets/common/app_card.dart with icon, title, value, trend, onTap, backgroundColor variants
- [X] T043 [P] Create StatusBadge widget in lib/presentation/widgets/common/status_badge.dart with text/icon, color variants (green, red, yellow, gray)
- [X] T044 [P] Create AppInput widget in lib/presentation/widgets/common/app_input.dart with label, text input, dropdown variants, validation message
- [X] T045 [P] Create TopAppBar widget in lib/presentation/widgets/common/top_app_bar.dart with back button, title, action button
- [X] T046 [P] Create BottomNavBar widget in lib/presentation/widgets/common/bottom_nav_bar.dart with 4-5 icons, active state highlighting

### PPE Indicator Widgets

- [X] T047 [P] Create PPEStatusWidget in lib/presentation/widgets/ppe_indicators/ppe_status_widget.dart with icon, label, status color coding
- [X] T048 [P] Create DetectionOverlay widget in lib/presentation/widgets/ppe_indicators/detection_overlay.dart with bounding box, color, worker ID
- [X] T049 [P] Create ComplianceBadge widget in lib/presentation/widgets/ppe_indicators/compliance_badge.dart with percentage, color variants
- [X] T050 [P] Create AlertBanner widget in lib/presentation/widgets/ppe_indicators/alert_banner.dart with message, severity, icon

### Main App Configuration

- [X] T051 Create main.dart in lib/ with GetMaterialApp, appTheme, routes, and initial route to splash screen
- [X] T052 Create SplashController in lib/presentation/controllers/splash_controller.dart with initialization logic and auto-navigation timing

**Checkpoint**: Foundation ready - all models, services, widgets, and infrastructure in place for user story implementation

---

## Phase 3: User Story 1 - App Launch & Onboarding (Priority: P1) 🎯 MVP

**Goal**: Deliver branded app entry point with automatic transition to home dashboard

**Independent Test**: Launch app → splash screen displays branding → auto-transitions to home dashboard with all 6 function cards visible

### Implementation for User Story 1

- [X] T053 [US1] Create SplashScreen in lib/presentation/screens/splash_screen.dart with centered logo, "SafeSight" app name, "AI-POWERED SAFETY COMPLIANCE" tagline
- [X] T054 [US1] Implement loading progress bar in SplashScreen with horizontal blue bar and "INITIALIZING SYSTEM" text
- [X] T055 [US1] Create HomeController in lib/presentation/controllers/home_controller.dart with systemStatus observable, card status observables, navigation methods
- [X] T056 [US1] Create HomeScreen in lib/presentation/screens/home_screen.dart with SafeSight branding, status banner, 2x3 function cards grid, SOS button, bottom navigation
- [X] T057 [US1] Implement function card widgets in HomeScreen: Monitoring (camera icon), Reports (document), Personnel (user), Thresholds (warning), Media (cloud), Alert History (triangle)
- [X] T058 [US1] Add status banner in HomeScreen with "ACTIVE MONITORING" and "All Systems Normal" text, green background
- [X] T059 [US1] Add circular SOS button in HomeScreen with red color, emergency alert functionality (stub for now)
- [X] T060 [US1] Add profile icon button in top-right of HomeScreen that navigates to settings
- [X] T061 [US1] Add BottomNavBar to HomeScreen with Home (active), Chat, Settings icons

**Checkpoint**: At this point, app launches successfully from splash to home dashboard with all navigation elements

---

## Phase 4: User Story 2 - Real-Time Safety Monitoring (Priority: P1) 🎯 MVP Core

**Goal**: Deliver live camera feed with AI-powered PPE detection overlays and violation alerts

**Independent Test**: Navigate to monitoring screen → camera feed displays → color-coded bounding boxes appear on detected persons → violation alerts show in banner

### Implementation for User Story 2

- [X] T062 [US2] Create MonitoringController in lib/presentation/controllers/monitoring_controller.dart with camera state, detection stream observable, alert state, controls (start/stop/camera toggle)
- [X] T063 [US2] Create MonitoringScreen in lib/presentation/screens/monitoring_screen.dart with full-screen camera background, top status bar, detection overlays, control bar, alert banner
- [X] T064 [US2] Implement camera initialization in MonitoringController using camera package with Controller, initialize, dispose lifecycle
- [X] T065 [US2] Implement top status bar in MonitoringScreen with semi-transparent background displaying "Detected: X", "Compliant: Y", "Non-Compliant: Z" counts
- [X] T066 [US2] Create DetectionOverlay widget with color-coded bounding boxes (green=compliant, red=non-compliant, yellow=partial) displaying worker ID and icons
- [X] T067 [US2] Implement DetectionStream WebSocket connection in MonitoringController with frame-by-frame detection result processing
- [X] T068 [US2] Implement alert banner in MonitoringScreen with red background, specific violation details (worker ID, missing PPE), icon
- [X] T069 [US2] Add control bar in MonitoringScreen above alert with camera toggle button, start/stop button (green with timer display), settings gear icon
- [X] T070 [US2] Handle error states in MonitoringScreen: camera unavailable (show placeholder), detection lost (reconnect logic), permission denied

**Checkpoint**: Real-time monitoring functional with camera feed, detection overlays, and violation alerts

---

## Phase 5: User Story 3 - Worker Registration & Management (Priority: P2)

**Goal**: Deliver worker registration form with validation for adding new personnel to the system

**Independent Test**: Navigate to add worker screen → fill form with valid/invalid data → validation works correctly → worker saves successfully

### Implementation for User Story 3

- [X] T071 [US3] Create WorkerController in lib/presentation/controllers/worker_controller.dart with form state, validation observables, submit method, department/job title options
- [X] T072 [US3] Create AddWorkerScreen in lib/presentation/screens/add_worker_screen.dart with form layout, back navigation, "Add New Worker" title
- [X] T073 [US3] Implement WorkerId text input in AddWorkerScreen with "Enter 8-digit ID" placeholder, real-time validation, inline error display ("Worker ID must be 8 digits")
- [X] T074 [US3] Implement FullName text input in AddWorkerScreen with "e.g., John Doe" placeholder
- [X] T075 [US3] Implement Department dropdown in AddWorkerScreen with "Select a department" placeholder, predefined options (Production, Maintenance, Safety)
- [X] T076 [US3] Implement JobTitle dropdown in AddWorkerScreen with "Select a job title" placeholder, department-dependent options (Production: Operator, Supervisor, Technician; Maintenance: Technician, Lead, Supervisor; Safety: Inspector, Officer, Manager)
- [X] T077 [US3] Implement RequiredPPE toggleable chips in AddWorkerScreen with options: Hard Hat, Safety Glasses, Vest, Gloves, Steel-toed Boots
- [X] T078 [US3] Add duplicate Worker ID validation in AddWorkerScreen that shows inline error "Worker ID already exists" when ID already exists in system
- [X] T079 [US3] Create "Add Worker" submit button in AddWorkerScreen with blue background, bottom placement
- [X] T080 [US3] Implement form submission in WorkerController with validation, duplicate check, success navigation to worker list

**Checkpoint**: Worker registration form complete with all validations, dropdowns, and chips working

---

## Phase 6: User Story 4 - Manual PPE Detection via Image Upload (Priority: P2)

**Goal**: Deliver image upload and analysis screen for spot-checking PPE compliance

**Independent Test**: Navigate to upload screen → upload image → analysis runs → results display with compliance percentage and item-by-item status

### Implementation for User Story 4

- [X] T081 [US4] Create UploadController in lib/presentation/controllers/upload_controller.dart with image selection state, upload progress, analysis result observable, scan method
- [X] T082 [US4] Create UploadDetectionScreen in lib/presentation/screens/upload_detection_screen.dart with SafeSight branding, back navigation, preview area, analysis status, compliance badge, action button
- [X] T083 [US4] Implement image picker integration in UploadController using image_picker package (camera/gallery selection)
- [X] T084 [US4] Create image preview area in UploadDetectionScreen that displays selected image with full-width aspect ratio
- [X] T085 [US4] Implement "ANALYZING INFRASTRUCTURE" status text below preview in UploadDetectionScreen during analysis
- [X] T086 [US4] Create three circular analysis icons in UploadDetectionScreen: "ANALYZE HARD HAT", "ANALYZE SAFETY GLASSES", "ANALYZE EAR PROTECTION"
- [X] T087 [US4] Create ComplianceBadge widget in UploadDetectionScreen with green background, "Compliance Secured - 98%" text, percentage display
- [X] T088 [US4] Implement item-by-item PPE status display in UploadDetectionScreen with checkmarks (compliant), warning triangles (violations)
- [X] T089 [US4] Implement "Initiate New Scan" button in UploadDetectionScreen with blue background, bottom placement
- [X] T090 [US4] Add mock UploadDetectionResult flow in UploadController with simulated analysis delay and result generation

**Checkpoint**: Image upload and analysis complete with status display and compliance results

---

## Phase 7: User Story 5 - Viewing Safety Reports & Analytics (Priority: P2)

**Goal**: Deliver reports dashboard with incident counts, compliance trends, and chart visualization

**Independent Test**: Navigate to reports screen → summary cards display metrics → chart area shows data → live updates toggle works

### Implementation for User Story 5

- [X] T091 [US5] Create ReportsController in lib/presentation/controllers/reports_controller.dart with reportData observable, liveUpdates toggle, refresh method, filter options
- [X] T092 [US5] Create ReportsScreen in lib/presentation/screens/reports_screen.dart with back navigation, "Reports" title, filter icon
- [X] T093 [US5] Create summary cards in ReportsScreen: Incidents card (red triangle icon, "-5%" trend green, "12" count red), Compliance card (blue shield icon, "+2%" trend green, "98%" blue)
- [X] T094 [US5] Implement "Live Updates" toggle switch in ReportsScreen for real-time data refresh
- [X] T095 [US5] Create "SAFETY INSIGHT ENGINE" chart card in ReportsScreen with placeholder for bar chart visualization
- [X] T096 [US5] Implement sync banner in ReportsScreen with "AI detection active. Reports are synchronized with edge sensors every 5 minutes." text
- [X] T097 [US5] Add bottom navigation to ReportsScreen with Live, Log, Team, Reports (active), Config tabs
- [X] T098 [US5] Implement mock ReportData loading in ReportsController with simulated metrics, trends, and chart data points
- [X] T099 [US5] Add filter icon action in ReportsScreen that opens date range or category filter dialog (stub for now)

**Checkpoint**: Reports dashboard complete with metrics, charts, and refresh functionality

---

## Phase 8: User Story 6 - Configuring Alerts & Notifications (Priority: P3)

**Goal**: Deliver alert configuration screen with toggle switches and delivery mode selection

**Independent Test**: Navigate to alert config screen → toggle alerts on/off → select delivery modes → commit changes saves preferences

### Implementation for User Story 6

- [X] T100 [US6] Create AlertConfigController in lib/presentation/controllers/alert_config_controller.dart with alertConfigs observable, deliveryMode state, commitChanges method
- [X] T101 [US6] Create AlertConfigScreen in lib/presentation/screens/alert_config_screen.dart with back navigation, "ALERT CONFIG" title, menu icon
- [X] T102 [US6] Implement "Safety Critical Systems" section in AlertConfigScreen with Stealth Mode (bell icon, toggle), PPE Compliance (shield icon, toggle), Prox Warning (toggle), Zone Incursion (toggle)
- [X] T103 [US6] Implement "Intelligence Feed" section in AlertConfigScreen with Safety Metrics (chart icon, toggle), System Status (refresh icon, toggle)
- [X] T104 [US6] Create toggle switch widgets in AlertConfigScreen with color coding (gray=off, cyan/pink=on)
- [X] T105 [US6] Implement delivery mode tabs for PPE Compliance alert in AlertConfigScreen with Audio, Haptic, Dual options, teal color for selected
- [X] T106 [US6] Create "COMMIT CHANGES" button in AlertConfigScreen with gradient (teal-to-purple) background, bottom placement
- [X] T107 [US6] Implement commitChanges in AlertConfigController that saves all alert configurations and shows confirmation
- [X] T108 [US6] Add bottom navigation to AlertConfigScreen with Grid, Eye (alerts active), Chart, User icons

**Checkpoint**: Alert configuration complete with all toggles, delivery modes, and commit functionality

---

## Phase 9: User Story 7 - App Usage Instructions (Priority: P3)

**Goal**: Deliver help and tutorials screen with searchable content and FAQ

**Independent Test**: Navigate to instructions screen → tabs display content → search works → tutorials and FAQs accessible

### Implementation for User Story 7

- [X] T109 [US7] Create InstructionsController in lib/presentation/controllers/instructions_controller.dart with selectedTab observable, searchQuery observable, tutorials list, faqs list
- [X] T110 [US7] Create InstructionsScreen in lib/presentation/screens/instructions_screen.dart with back navigation, "App Usage" title, help icon
- [X] T111 [US7] Create search bar in InstructionsScreen with "Search safety tutorials..." placeholder, magnifying glass icon
- [X] T112 [US7] Implement content tabs in InstructionsScreen: "Getting Started" (blue), "AI Detection" (gray), "Safety Alerts" (gray) with active state highlighting
- [X] T113 [US7] Create "Featured Tutorials" section in InstructionsScreen with card-based layout: Activating AI Scanning (blue icon), Hazard Identification (orange), Safety Reports (green), Worker Profiles (purple)
- [X] T114 [US7] Implement tutorial cards in InstructionsScreen with icon, title, description, right arrow, color-coded by category
- [X] T115 [US7] Create "Common Questions" section in InstructionsScreen with expandable cards and downward arrows
- [X] T116 [US7] Implement tutorial detail navigation in InstructionsController that shows expanded content when card is tapped
- [X] T117 [US7] Implement search functionality in InstructionsController that filters tutorials and FAQs by query string
- [X] T118 [US7] Add bottom navigation to InstructionsScreen with Real-time, Upload, Workers, Reports, Settings tabs

**Checkpoint**: Instructions/help screen complete with tabs, tutorials, FAQs, and search

---

## Phase 10: User Story 8 - Managing App Settings & Profile (Priority: P3)

**Goal**: Deliver settings screen with profile card, preferences, toggles, and logout

**Independent Test**: Navigate to settings screen → profile card displays → toggle settings work → log out returns to login

### Implementation for User Story 8

- [X] T119 [US8] Create SettingsController in lib/presentation/controllers/settings_controller.dart with userSettings observable, updateProfile method, toggle methods, logout method
- [X] T120 [US8] Create SettingsScreen in lib/presentation/screens/settings_screen.dart with back navigation, three-dot menu, profile card, settings sections, logout button
- [X] T121 [US8] Create profile card in SettingsScreen with avatar (hard hat placeholder), "Jane Doe" name, "Senior Safety Inspector" title, "ID: 78910 - SF", Edit button, green online indicator
- [X] T122 [US8] Implement "General Preferences" section in SettingsScreen with App Language ("English (US)"), Appearance ("System Dark"), chevron arrows
- [X] T123 [US8] Implement "Safety & Alerts" section in SettingsScreen with Hazard Alerts toggle (enabled), Safe Zone Monitoring toggle (enabled)
- [X] T124 [US8] Implement "Security" section in SettingsScreen with Biometric Auth (arrow), Privacy Settings (arrow)
- [X] T125 [US8] Create "Log Out" button in SettingsScreen with red background, logout icon, bottom placement
- [X] T126 [US8] Add footer in SettingsScreen with "SAFESIGHT V1.0.0 (STABLE)" text
- [X] T127 [US8] Implement toggle switches in SettingsController with hazardAlerts and safeZoneMonitoring observables
- [X] T128 [US8] Implement profile edit action in SettingsController that opens edit profile dialog (stub for now)
- [X] T129 [US8] Implement logout in SettingsController that clears stored credentials and navigates to splash/login
- [X] T130 [US8] Add bottom navigation to SettingsScreen with Dashboard, Vision, Logs, Settings (active), center blue action button

**Checkpoint**: Settings screen complete with profile card, toggles, sections, and logout

---

## Phase 11: Polish & Cross-Cutting Concerns

**Purpose**: Final integration, consistency checks, and completion across all screens

- [X] T131 [P] Add splash screen transition timing in SplashController - 2-3 second display before navigating to home
- [X] T132 [P] Ensure all screens use consistent SafeSight branding name across the app (update any remaining hardcoded variants)
- [X] T133 [P] Validate all color coding is consistent: green (#4CAF50), red (#F44336), yellow (#FFC107), blue (#2196F3) across all screens
- [X] T134 [P] Verify all back navigation buttons have consistent styling and behavior
- [X] T135 [P] Ensure all form inputs use AppInput widget for consistency
- [X] T136 [P] Verify all status badges use StatusBadge widget for consistency
- [X] T137 [P] Add loading skeletons to screens with data fetching: HomeScreen, ReportsScreen, SettingsScreen
- [X] T138 [P] Add error state handling to all API controller methods with user-friendly error messages
- [X] T139 [P] Verify all bottom navigation bars use BottomNavBar widget with consistent styling
- [X] T140 [P] Add empty state handling to screens with list data: ReportsScreen (no data), AlertConfigScreen (no alerts), InstructionsScreen (search returns no results)
- [X] T141 Review all controllers for proper resource disposal (onClose methods: camera controller, streams, subscriptions)
- [X] T142 Add network connectivity indicator using connectivity_plus - show banner when offline
- [X] T143 [P] Create local settings storage using shared_preferences for language, theme, hazard alerts, safe zone monitoring
- [X] T144 [P] Create Hive boxes for offline data caching: workers (Worker model), reports (ReportData model), uploads (UploadDetectionResult model)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-10)**: All depend on Foundational phase completion
- - User stories can proceed in parallel (if staffed) or sequentially in priority order (P1 → P2 → P3)
- **Polish (Phase 11)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P1)**: Can start after Foundational (Phase 2) - Uses DetectionOverlay widget, AlertBanner widget from Phase 2
- **User Story 3 (P2)**: Can start after Foundational (Phase 2) - Uses AppInput, StatusBadge widgets from Phase 2
- **User Story 4 (P2)**: Can start after Foundational (Phase 2) - Uses PPEStatusWidget, ComplianceBadge widgets from Phase 2
- **User Story 5 (P2)**: Can start after Foundational (Phase 2) - Uses AppCard widget from Phase 2
- **User Story 6 (P3)**: Can start after Foundational (Phase 2) - Uses AppButton, StatusBadge widgets from Phase 2
- **User Story 7 (P3)**: Can start after Foundational (Phase 2) - Uses AppCard, AppInput widgets from Phase 2
- **User Story 8 (P3)**: Can start after Foundational (Phase 2) - Uses BottomNavBar, AppButton widgets from Phase 2

### Within Each User Story

- Controllers before screens
- Models before controllers
- Services before controllers (services already created in Phase 2)
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

**Setup Phase (all parallel)**:
```bash
Task: T002 - Initialize Flutter dependencies
Task: T003 - Create app colors
Task: T004 - Create app strings
Task: T005 - Create dark theme
Task: T006 - Create text styles
Task: T007 - Create validators
Task: T008 - Create formatters
Task: T009 - Create routes
Task: T010 - Create route generator
```

**Foundational Phase (models parallel)**:
```bash
Task: T011-T029 - All data models (Worker, PPEItem, DetectionResult, etc.)
```

**Foundational Phase (widgets parallel)**:
```bash
Task: T041-T046 - All common widgets
Task: T047-T050 - All PPE indicator widgets
```

**User Story 1 + User Story 2 (can run in parallel after foundational)**:
```bash
# US1 tasks:
Task: T053 - Create SplashScreen
Task: T055 - Create HomeController
Task: T056 - Create HomeScreen

# US2 tasks (can run simultaneously):
Task: T062 - Create MonitoringController
Task: T063 - Create MonitoringScreen
```

---

## Implementation Strategy

### MVP First (P1 Stories Only - Core Navigation)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1 (Splash + Home)
4. **STOP and VALIDATE**: Test app launch and navigation independently
5. Deploy/demo if ready

**MVP delivers**: Functional app launch with home dashboard, all navigation working, branded splash screen

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 (P1) → Test independently → Deploy/Demo (MVP base!)
3. Add User Story 2 (P1) → Test independently → Deploy/Demo (MVP core!)
4. Add User Story 3 (P2) → Test independently → Deploy/Demo
5. Add User Story 4 (P2) → Test independently → Deploy/Demo
6. Add User Story 5 (P2) → Test independently → Deploy/Demo
7. Add User Stories 6-8 (P3) → Test independently → Deploy/Demo
8. Final polish → Complete feature set

Each story adds value without breaking previous stories.

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Stories 1 & 2 (P1 - core features)
   - Developer B: User Stories 3 & 4 (P2 - data management)
   - Developer C: User Stories 5, 6, 7, 8 (P3 - secondary features)
3. Stories complete and integrate independently

---

## Task Summary

**Total Tasks**: 144
- **Setup**: 10 tasks
- **Foundational**: 40 tasks (models, services, repositories, widgets)
- **User Story 1 (P1)**: 9 tasks
- **User Story 2 (P1)**: 9 tasks
- **User Story 3 (P2)**: 10 tasks
- **User Story 4 (P2)**: 10 tasks
- **User Story 5 (P2)**: 9 tasks
- **User Story 6 (P3)**: 9 tasks
- **User Story 7 (P3)**: 10 tasks
- **User Story 8 (P3)**: 12 tasks
- **Polish**: 14 tasks

**Parallel Opportunities**: 40+ tasks marked with [P] can run in parallel, including all foundational models, widgets, and many user story tasks

**MVP Scope**: Phases 1-3 (User Stories 1 & 2) = 29 tasks plus setup = 68 tasks total for core navigation and real-time monitoring basics

**Independent Test Criteria**: Each user story can be implemented and tested in isolation, relying only on foundational Phase 2 infrastructure.

**Format Validation**: All 144 tasks follow the required checklist format: `- [ ] [ID] [P?] [Story?] Description with file path`
