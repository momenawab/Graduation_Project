# Feature Specification: UI Screens Design Specification

**Feature Branch**: `001-ui-screens`
**Created**: 2026-02-04
**Status**: Draft
**Input**: UI screens specification for industrial safety monitoring app - define 9 screen layouts, components, navigation flow, and visual design

## Clarifications

### Session 2026-02-04

- Q: What is the consistent app name to use across all screens? → A: SafeSight
- Q: What happens when a duplicate Worker ID is entered? → A: Show inline error "Worker ID already exists"
- Q: What predefined departments and job titles are available? → A: Minimal list: Production, Maintenance, Safety with generic job titles

## User Scenarios & Testing *(mandatory)*

### User Story 1 - App Launch & Onboarding (Priority: P1)

A new user launches the industrial safety monitoring app for the first time. They see the splash screen while the system initializes, then navigate to the home dashboard to begin monitoring safety compliance.

**Why this priority**: This is the entry point for all users. Without a functional launch and home screen, no other features can be accessed.

**Independent Test**: Can be tested by launching the app and verifying the splash screen appears, followed by the home/dashboard screen with all navigation elements visible.

**Acceptance Scenarios**:

1. **Given** the app is not running, **When** the user launches the app, **Then** the splash screen displays with app logo, name, and loading indicator
2. **Given** the splash screen is visible, **When** initialization completes, **Then** the home/dashboard screen appears with all status indicators
3. **Given** the home screen is displayed, **When** the user views the screen, **Then** all six function cards are visible and tappable

---

### User Story 2 - Real-Time Safety Monitoring (Priority: P1)

A safety supervisor activates the real-time monitoring feature to view a live camera feed of workers. The app displays PPE detection overlays with color-coded bounding boxes indicating compliance status for each detected person.

**Why this priority**: This is the core feature of the app - real-time AI-powered safety monitoring. It delivers the primary value proposition.

**Independent Test**: Can be tested by navigating to the real-time monitoring screen and verifying the camera feed displays with detection overlays and status indicators.

**Acceptance Scenarios**:

1. **Given** the home screen is displayed, **When** the user taps the Monitoring card, **Then** the real-time monitoring screen opens with camera feed
2. **Given** a person is visible in the camera feed, **When** PPE detection runs, **Then** a color-coded bounding box appears (green=compliant, red=non-compliant, yellow=partial)
3. **Given** a violation is detected, **When** the alert appears, **Then** the alert banner shows specific violation details (worker ID, missing PPE)

---

### User Story 3 - Worker Registration & Management (Priority: P2)

An administrator needs to add a new worker to the system. They navigate to the add worker form, enter the worker's details including ID, name, department, job title, and required PPE.

**Why this priority**: Worker data is essential for face recognition and personalized violation tracking. This can be added after core monitoring is functional.

**Independent Test**: Can be tested by navigating to the add worker screen, filling in all fields, and submitting the form.

**Acceptance Scenarios**:

1. **Given** the home screen is displayed, **When** the user taps the Personnel card, **Then** the add worker details screen appears
2. **Given** the add worker form is displayed, **When** the user enters an invalid Worker ID, **Then** a validation warning appears below the field
3. **Given** all valid fields are entered, **When** the user taps "Add Worker", **Then** the worker is saved and the user returns to the personnel list

---

### User Story 4 - Manual PPE Detection via Image Upload (Priority: P2)

A safety officer takes a photo of an area and uploads it for PPE analysis. The app displays the image, analyzes it for PPE compliance, and shows detection results with compliance status.

**Why this priority**: Provides an alternative to real-time monitoring for spot-checking areas. Can be implemented after core real-time monitoring.

**Independent Test**: Can be tested by uploading an image and verifying the analysis screen displays with detection results.

**Acceptance Scenarios**:

1. **Given** the home screen is displayed, **When** the user taps the Media/Upload card, **Then** the image upload for detection screen appears
2. **Given** an image is selected, **When** the user initiates the scan, **Then** the app displays "Analyzing Infrastructure" status
3. **Given** analysis is complete, **When** results are displayed, **Then** the compliance percentage and item-by-item status are shown

---

### User Story 5 - Viewing Safety Reports & Analytics (Priority: P2)

A safety manager reviews the reports screen to view incident counts, compliance rates, and trend data. They access summary cards and charts showing safety performance over time.

**Why this priority**: Historical data and trends are important for management but not required for day-to-day monitoring operations.

**Independent Test**: Can be tested by navigating to the reports screen and verifying all metrics and charts are displayed.

**Acceptance Scenarios**:

1. **Given** the home screen is displayed, **When** the user taps the Reports card, **Then** the reports screen appears with summary cards
2. **Given** the reports screen is displayed, **When** the user views the metrics, **Then** incidents count, compliance percentage, and trends are visible
3. **Given** the reports screen is displayed, **When** live updates toggle is enabled, **Then** data refreshes periodically

---

### User Story 6 - Configuring Alerts & Notifications (Priority: P3)

A user customizes their alert preferences by enabling/disabling specific notification types and selecting delivery methods (audio, haptic, or dual).

**Why this priority**: Alert configuration is a personalization feature. The app can function with default alert settings.

**Independent Test**: Can be tested by navigating to the alert configuration screen and toggling various alert options.

**Acceptance Scenarios**:

1. **Given** the home screen is displayed, **When** the user taps the Alert History/Config option, **Then** the alert configuration screen appears
2. **Given** the alert config screen is displayed, **When** the user toggles PPE Compliance alert, **Then** the toggle changes color to indicate the new state
3. **Given** PPE Compliance is enabled, **When** the user selects a delivery mode (Audio/Haptic/Dual), **Then** the selected tab is highlighted

---

### User Story 7 - Accessing App Usage Instructions (Priority: P3)

A new or confused user opens the App Usage section to find tutorials, troubleshooting guides, and step-by-step instructions for using the app's features.

**Why this priority**: Help content is important for onboarding but does not block core functionality.

**Independent Test**: Can be tested by navigating to the App Usage screen and verifying tutorials and FAQs are accessible.

**Acceptance Scenarios**:

1. **Given** the home screen is displayed, **When** the user accesses the App Usage section, **Then** the instructions screen appears with tabs for different topics
2. **Given** the App Usage screen is displayed, **When** the user taps a tutorial card, **Then** detailed instructions for that topic appear
3. **Given** the App Usage screen is displayed, **When** the user searches for a topic, **Then** relevant results are displayed

---

### User Story 8 - Managing App Settings & Profile (Priority: P3)

A user navigates to the settings screen to view their profile, change app preferences, configure safety toggles, or log out.

**Why this priority**: Settings and profile management are necessary for personalization but not for core safety monitoring functionality.

**Independent Test**: Can be tested by navigating to the settings screen and verifying all options are accessible and functional.

**Acceptance Scenarios**:

1. **Given** the home screen is displayed, **When** the user taps the Settings tab, **Then** the settings screen appears with profile card and options
2. **Given** the settings screen is displayed, **When** the user toggles Hazard Alerts, **Then** the toggle state changes and is saved
3. **Given** the settings screen is displayed, **When** the user taps Log Out, **Then** the user is signed out and returned to the login screen

---

### Edge Cases

- What happens when the camera feed is interrupted or unavailable during real-time monitoring?
- How does the system handle invalid Worker ID formats during worker registration?
- **What happens when a duplicate Worker ID is entered during worker registration? → System validates and shows inline error "Worker ID already exists"**
- What happens when an uploaded image for detection cannot be analyzed (too dark, no people detected)?
- How does the app behave when network connectivity is lost during report loading?
- What happens when the user attempts to enable an alert type that requires permissions not granted?

## Requirements *(mandatory)*

### Functional Requirements

#### Splash Screen
- **FR-001**: System MUST display a splash screen with app logo, name ("SafeSight"), and tagline during app initialization
- **FR-002**: System MUST show a loading progress indicator on the splash screen
- **FR-003**: System MUST transition from splash screen to home screen automatically after initialization completes

#### Home/Dashboard Screen
- **FR-004**: System MUST display a dashboard with six primary function cards: Monitoring, Reports, Personnel, Thresholds, Media, Alert History
- **FR-005**: System MUST show a status banner indicating system health (Active Monitoring/All Systems Normal)
- **FR-006**: System MUST display a profile icon in the top-right corner for account access
- **FR-007**: System MUST include an SOS emergency button for immediate alert activation
- **FR-008**: System MUST show real-time status indicators on each card (e.g., "4 cameras active", "0 new reports")

#### Real-Time Monitoring Screen
- **FR-009**: System MUST display a live camera feed occupying the majority of the screen
- **FR-010**: System MUST overlay color-coded bounding boxes on detected persons (green=compliant, red=non-compliant, yellow=partial)
- **FR-011**: System MUST display a top status bar showing Detected count, Compliant count, and Non-Compliant count
- **FR-012**: System MUST show an alert banner at the bottom for any violations detected, including worker ID and missing PPE
- **FR-013**: System MUST provide controls for camera toggle, start/stop monitoring, and settings

#### Add Worker Details Screen
- **FR-014**: System MUST provide form fields for Worker ID, Full Name, Department, Job Title
- **FR-015**: System MUST validate Worker ID is 8 digits and show inline warning if invalid
- **FR-015A**: System MUST validate Worker ID is unique and show inline error "Worker ID already exists" if duplicate
- **FR-016**: System MUST provide dropdown selectors for Department and Job Title
- **FR-017**: System MUST allow selection of Required PPE via toggleable chips (Hard Hat, Safety Glasses, Vest, Gloves, Steel-toed Boots)
- **FR-018**: System MUST display an "Add Worker" button to submit the form

#### Image Upload for Detection Screen
- **FR-019**: System MUST provide an image preview area for the uploaded photo
- **FR-020**: System MUST display analysis status during PPE detection (e.g., "Analyzing Infrastructure")
- **FR-021**: System MUST show compliance percentage score after analysis completes
- **FR-022**: System MUST display item-by-item PPE status with checkmarks or warning icons
- **FR-023**: System MUST provide an "Initiate New Scan" button for additional analyses

#### Reports Screen
- **FR-024**: System MUST display summary cards for Incidents (count with trend) and Compliance (percentage with trend)
- **FR-025**: System MUST show a chart area for safety insight visualization
- **FR-026**: System MUST include a "Live Updates" toggle for real-time data refresh
- **FR-027**: System MUST display a banner indicating AI detection status and data sync interval

#### Alert Configuration Screen
- **FR-028**: System MUST group alerts into "Safety Critical Systems" and "Intelligence Feed" sections
- **FR-029**: System MUST provide toggle switches for each alert type (PPE Compliance, Prox Warning, Stealth Mode, Zone Incursion, Safety Metrics)
- **FR-030**: System MUST allow selection of delivery mode (Audio, Haptic, Dual) for PPE Compliance alerts
- **FR-031**: System MUST display a "Commit Changes" button to save alert configuration

#### App Usage Instructions Screen
- **FR-032**: System MUST provide tabs for "Getting Started", "AI Detection", and "Safety Alerts" content
- **FR-033**: System MUST display featured tutorial cards with icons, titles, and descriptions
- **FR-034**: System MUST include a search bar for finding specific topics
- **FR-035**: System MUST show expandable "Common Questions" cards for troubleshooting

#### Settings Screen
- **FR-036**: System MUST display a profile card with avatar, name, title, and employee ID
- **FR-037**: System MUST provide setting sections for General Preferences, Safety & Alerts, and Security
- **FR-038**: System MUST include toggle switches for Hazard Alerts and Safe Zone Monitoring
- **FR-039**: System MUST provide options for App Language, Appearance, Biometric Auth, and Privacy Settings
- **FR-040**: System MUST display a Log Out button

#### Navigation & Layout
- **FR-041**: System MUST provide consistent bottom navigation across all main screens
- **FR-042**: System MUST use a dark theme for high contrast in industrial environments
- **FR-043**: System MUST use consistent color coding: green (normal/compliant), red (critical/non-compliant), yellow (warning/partial), blue (navigation/active)
- **FR-044**: System MUST include back navigation buttons on all non-home screens

### Key Entities

- **Screen**: Represents a distinct page in the app with a specific purpose and set of UI components
- **Card**: A reusable UI container with icon, title, status, and optional action that users can tap
- **Alert**: A notification type with title, description, enabled state, and delivery mode
- **Worker Profile**: Contains Worker ID, Full Name, Department, Job Title, and Required PPE list
- **PPE Item**: Represents a piece of personal protective equipment with name, detection status, and compliance indicator

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can navigate from app launch to any primary function within 3 taps
- **SC-002**: Real-time monitoring screen displays detection overlays within 1 second of person detection
- **SC-003**: All screens are readable in various lighting conditions due to high contrast dark theme
- **SC-004**: Color-coded status indicators (green/red/yellow) are instantly recognizable without reading text
- **SC-005**: New users can complete the worker registration form in under 2 minutes on first attempt
- **SC-006**: Alert configuration changes are saved and applied immediately after confirmation
- **SC-007**: App usage instructions are accessible within 2 taps from any screen

## UI Screen Specifications

### Screen 1: Splash Screen

**Purpose**: Display app branding while system initializes

**Layout & Components**:
- **Background**: Deep navy blue or dark (#0A1929)
- **Central Element**: Circular icon with eye symbol in blue and white
- **App Name**: "Safe Eye" in large bold white text (36-48pt)
- **Tagline**: "AI-POWERED SAFETY COMPLIANCE" in smaller caps text
- **Progress Bar**: Horizontal blue loading bar at bottom
- **Progress Text**: "INITIALIZING SYSTEM" in small text above progress bar

**Visual Priority**: Logo → App Name → Tagline → Loading Indicator

**Responsive Rules**: Vertically centered layout with consistent margins on all screen sizes

---

### Screen 2: Home/Dashboard Screen

**Purpose**: Main hub for accessing all app functions with at-a-glance system status

**Layout & Components**:
- **Top Bar**: "SafeSight" branding with circular profile icon (top-right)
- **Status Banner**: Dark green background with "ACTIVE MONITORING" and "All Systems Normal"
- **Function Cards** (2x3 grid):
  1. Monitoring (camera icon, "4 cameras active")
  2. Reports (document icon, "0 new reports")
  3. Personnel (user icon, "0 alerts")
  4. Thresholds (warning icon, "All within limits")
  5. Media (cloud icon, "0 new uploads")
  6. Alert History (triangle icon, "0 critical")
- **SOS Button**: Red circular button at bottom center
- **Bottom Navigation**: Home, Chat, Settings icons

**Visual Priority**: Status Banner → Function Cards → SOS Button

**Responsive Rules**: Cards maintain square aspect ratio; grid adjusts for tablet (3 columns)

---

### Screen 3: Real-Time Monitoring Screen

**Purpose**: Display live camera feed with AI-powered PPE detection overlays

**Layout & Components**:
- **Full-Screen Background**: Live camera feed
- **Top Status Bar**: Semi-transparent dark bar with "Detected: 5", "Compliant: 4", "Non-Compliant: 1"
- **Detection Overlays**: Color-coded bounding boxes (green/red/yellow) with icons and worker IDs
- **Alert Banner**: Red banner at bottom with specific violation details
- **Control Bar** (above alert): Camera toggle, start/stop button (green with timer), settings gear

**Visual Priority**: Detection Overlays → Alert Banner → Status Counts

**Responsive Rules**: Camera feed fills available space; overlays scale with detected objects

---

### Screen 4: Add Worker Details Screen

**Purpose**: Form for registering new workers with their PPE requirements

**Layout & Components**:
- **Header**: Back arrow, "Add New Worker" title (centered)
- **Form Fields** (vertical stack):
  - Worker ID (text input with "Enter 8-digit ID" placeholder)
  - Full Name (text input with "e.g., John Doe" placeholder)
  - Department (dropdown with "Select a department")
  - Job Title (dropdown with "Select a job title")
  - Required PPE (toggleable chips: Hard Hat, Safety Glasses, Vest, Gloves, Steel-toed Boots)
- **Validation**: Yellow warning icon with "Worker ID must be 8 digits" message
- **Submit Button**: Blue "Add Worker" button at bottom

**Visual Priority**: Form Fields → Validation Messages → Submit Button

**Responsive Rules**: Full-width inputs; chips wrap to multiple lines on smaller screens

---

### Screen 5: Image Upload for Detection Screen

**Purpose**: Upload and analyze images for PPE compliance

**Layout & Components**:
- **Header**: "SafeSight" branding with back navigation
- **Preview Area**: Large image display showing worker in PPE
- **Status Text**: "ANALYZING INFRASTRUCTURE" below preview
- **Analysis Icons**: Three circular icons for "ANALYZE HARD HAT", "ANALYZE SAFETY GLASSES", "ANALYZE EAR PROTECTION"
- **Compliance Badge**: Green "Compliance Secured - 98%" badge
- **Item Status**: Checkmarks for "Eye Protection" and "Ear Protection"; warning triangle for "Critical Violation"
- **Action Button**: Blue "INITIATE NEW SCAN" button at bottom

**Visual Priority**: Preview Area → Compliance Badge → Item Status → Action Button

**Responsive Rules**: Preview area maintains aspect ratio; elements stack vertically

---

### Screen 6: Reports Screen

**Purpose**: Display safety metrics, compliance trends, and analytics

**Layout & Components**:
- **Header**: Back arrow, "Reports" title, filter icon
- **Summary Cards**:
  - Incidents: Red triangle icon, "-5%" trend (green), "12" count (red)
  - Compliance: Blue shield icon, "+2%" trend (green), "98%" (blue)
- **Live Updates Toggle**: Switch for real-time data refresh
- **Chart Section**: "SAFETY INSIGHT ENGINE" card with bar chart placeholder
- **Sync Banner**: "AI detection active. Reports are synchronized with edge sensors every 5 minutes."
- **Bottom Navigation**: Live, Log, Team, Reports (active), Config tabs

**Visual Priority**: Summary Cards → Chart → Sync Status

**Responsive Rules**: Cards expand on tablet; chart uses full available width

---

### Screen 7: Alert Configuration Screen

**Purpose**: Customize alert preferences and delivery methods

**Layout & Components**:
- **Header**: Back arrow, "ALERT CONFIG" title, menu icon
- **Safety Critical Systems Section**:
  - Stealth Mode (bell icon, toggle)
  - PPE Compliance (shield icon, toggle with Audio/Haptic/Dual tabs)
  - Prox Warning (toggle enabled - cyan)
  - Zone Incursion (toggle)
- **Intelligence Feed Section**:
  - Safety Metrics (chart icon, toggle)
  - System Status (refresh icon, toggle)
- **Commit Button**: Gradient (teal-to-purple) "COMMIT CHANGES" button at bottom
- **Bottom Navigation**: Grid, Eye (alerts active), Chart, User icons

**Visual Priority**: Enabled Toggles → Delivery Mode Tabs → Commit Button

**Responsive Rules**: Full-width list items; toggle controls right-aligned

---

### Screen 8: App Usage Instructions Screen

**Purpose**: Provide tutorials, guides, and troubleshooting support

**Layout & Components**:
- **Header**: Back arrow, "App Usage" title, help icon
- **Search Bar**: "Search safety tutorials..." with magnifying glass icon
- **Content Tabs**: "Getting Started" (active), "AI Detection", "Safety Alerts"
- **Featured Tutorials Section** (card-based):
  - Activating AI Scanning (blue icon)
  - Hazard Identification (orange icon)
  - Safety Reports (green icon)
  - Worker Profiles (purple icon)
- **Common Questions Section**: Expandable cards with downward arrows
- **Bottom Navigation**: Real-time, Upload, Workers, Reports, Settings tabs

**Visual Priority**: Content Tabs → Featured Tutorials → Search Bar → Questions

**Responsive Rules**: Cards expand to fill width; questions stack vertically

---

### Screen 9: Settings Screen

**Purpose**: Manage profile, app preferences, and safety configurations

**Layout & Components**:
- **Header**: Back arrow, three-dot menu
- **Profile Card**: Avatar with hard hat, "Jane Doe", "Senior Safety Inspector", "ID: 78910 - SF", Edit button, green online indicator
- **General Preferences Section**:
  - App Language: "English (US)" with arrow
  - Appearance: "System Dark" with arrow
- **Safety & Alerts Section**:
  - Hazard Alerts: Toggle (enabled)
  - Safe Zone Monitoring: Toggle (enabled)
- **Security Section**:
  - Biometric Auth with arrow
  - Privacy Settings with arrow
- **Log Out Button**: Red button with logout icon
- **Footer**: "SAFESIGHT V1.0.0 (STABLE)"
- **Bottom Navigation**: Dashboard, Vision, Logs, Settings (active), center blue action button

**Visual Priority**: Profile Card → Safety Toggles → Log Out Button

**Responsive Rules**: Full-width sections; avatar maintains fixed size

---

## Reusable UI Components

### 1. PPE Status Indicator Widget
**Purpose**: Display compliance status for individual PPE items
**Elements**: Icon (checkmark/warning/cross), Label, Color-coded background
**Variants**: Helmet, Vest, Shoes, Glasses, Gloves

### 2. Summary Card
**Purpose**: Display key metrics with trends
**Elements**: Icon, Title, Value, Trend indicator (+/- percentage), Background color
**Usage**: Reports, Home dashboard

### 3. Alert Card
**Purpose**: Display notification or alert with action
**Elements**: Icon, Title, Description, Toggle switch, Optional delivery mode tabs
**Usage**: Alert configuration, Notification list

### 4. Tutorial Card
**Purpose**: Present educational content
**Elements**: Color-coded icon, Title, Description, Right arrow
**Usage**: App Usage instructions

### 5. Form Input Field
**Purpose**: Standardized text/dropdown input
**Elements**: Label (top), Input field (dark background), Placeholder text, Validation message (below)
**Variants**: Text input, Dropdown, Toggle chips

### 6. Status Badge
**Purpose**: Quick visual status indicator
**Elements**: Circular or rounded background, Icon/Text, Color coding
**Variants**: Compliant (green), Non-compliant (red), Partial (yellow), Critical (red)

### 7. Bottom Navigation Bar
**Purpose**: Consistent navigation across main screens
**Elements**: 4-5 icons with labels, Active state highlighting, Optional center action button

### 8. Top Header Bar
**Purpose**: Screen identification and navigation
**Elements**: Back button (left), Title (centered), Action/menu icon (right)

## Navigation Flow

```
Splash Screen
     |
     v
Home/Dashboard
     |
     +---> Real-Time Monitoring
     |         |
     |         +---> Detection Results (overlay)
     |
     +---> Add Worker Details
     |         |
     |         +---> Worker List (Personnel)
     |
     +---> Image Upload for Detection
     |         |
     |         +---> Analysis Results
     |
     +---> Reports
     |
     +---> Alert Configuration
     |
     +---> App Usage Instructions
     |
     +---> Settings
```

**Navigation Rules**:
- All non-home screens include a back button to return to the previous screen
- Bottom navigation provides direct access to Home, Real-time, Reports, Settings
- Emergency SOS button is always accessible on home screen
- Profile icon in top-right leads to quick profile view

## Responsive Design Rules

### Mobile-First (Primary Target: 360-430px width)
- Single column layouts for all lists
- Cards stack vertically
- Touch targets minimum 44x44px
- Text scales proportionally (body: 14-16px, headings: 20-24px)

### Tablet-Ready (768px+ width)
- Dashboard grid expands to 3 columns
- Charts utilize full available width
- Side-by-side layouts for forms (labels left, inputs right)
- Larger touch targets and increased spacing

### Breakpoints
- Small: < 375px
- Medium: 375px - 768px
- Large: > 768px

## Visual Design System

### Color Palette
- **Background**: #121212 (primary), #1E1E1E (cards), #0A1929 (splash)
- **Primary**: #2196F3 (blue - navigation, active states)
- **Success/Compliant**: #4CAF50 (green)
- **Warning/Partial**: #FFC107 (yellow/amber)
- **Error/Non-Compliant**: #F44336 (red)
- **Text**: #FFFFFF (primary), #B0B0B0 (secondary), #757575 (disabled)

### Typography
- **Headings**: Sans-serif, bold, 20-28px
- **Body**: Sans-serif, regular, 14-16px
- **Captions**: Sans-serif, 12px
- **Monospace**: For IDs and codes

### Icons
- **Style**: Outline or filled, consistent stroke width
- **Size**: 24px (standard), 32px (large), 16px (small)
- **Color**: Inherit from text or use semantic colors

### Spacing
- **Unit**: 8px base grid
- **Padding**: 16px (standard), 24px (large)
- **Margins**: 8px between related items, 16px between sections
- **Border Radius**: 8px (cards), 4px (inputs), 50% (circular buttons)

## Assumptions

1. The app will support both iOS and Android platforms
2. Dark theme is the default and only theme (based on all screens showing dark backgrounds)
3. Face recognition and PPE detection services will be provided by the backend
4. The app will require camera permissions for real-time monitoring
5. Worker ID is an 8-digit numeric identifier
6. **Departments are predefined: Production, Maintenance, Safety**
7. **Job Titles by Department:**
   - **Production**: Operator, Supervisor, Technician
   - **Maintenance**: Technician, Lead, Supervisor
   - **Safety**: Inspector, Officer, Manager
8. Reports and analytics data will be fetched from a backend service
9. The app requires network connectivity for most features
10. SOS button triggers alerts to configured recipients
11. Biometric authentication refers to device fingerprint or face recognition
