# Data Model: UI Screens Design Specification

**Feature**: 001-ui-screens
**Date**: 2026-02-04
**Purpose**: Define data entities, models, and their relationships for the industrial safety monitoring app

## Entity Overview

| Entity | Purpose | Key Fields |
|--------|---------|------------|
| Worker | Personnel profile for face recognition and tracking | id, name, department, jobTitle, requiredPpe |
| PPEItem | Personal protective equipment with status | type, status, lastDetected |
| DetectionResult | Real-time detection result from camera stream | workerId, ppeStatus, boundingBox, timestamp |
| AlertConfig | User's notification preferences | alertType, enabled, deliveryMode |
| ReportData | Aggregated safety metrics and trends | incidents, compliance, trend, dateRange |
| SystemStatus | Overall system health status | status, activeCameras, lastUpdate |

## Entity Definitions

### Worker

Represents a registered worker/personnel in the system.

**Fields**:
| Field | Type | Validation | Description |
|-------|------|------------|-------------|
| id | String | 8 digits, required | Unique worker identifier |
| fullName | String | 2-100 chars | Worker's full name |
| department | String | From predefined list | Department name |
| jobTitle | String | From predefined list | Job title/role |
| requiredPpe | List<PPEType> | Non-empty | Required PPE for this role |
| faceId | String? | Optional | Face recognition template ID (future) |
| createdAt | DateTime | Auto-generated | Registration timestamp |
| violationCount | int | >= 0 | Total PPE violations |

**PPEType Enum**:
```dart
enum PPEType {
  hardHat,
  safetyGlasses,
  vest,
  gloves,
  steelToedBoots,
  earProtection
}
```

**State Transitions**:
```
[NEW] -> [REGISTERED] -> [ACTIVE]
                    -> [SUSPENDED] -> [ACTIVE]
                    -> [DELETED]
```

**JSON Example**:
```json
{
  "id": "12345678",
  "fullName": "John Doe",
  "department": "Production",
  "jobTitle": "Machine Operator",
  "requiredPpe": ["hardHat", "safetyGlasses", "vest", "steelToedBoots"],
  "faceId": "face_template_123",
  "createdAt": "2026-02-04T10:00:00Z",
  "violationCount": 3
}
```

---

### PPEItem

Represents a single PPE item and its detection status.

**Fields**:
| Field | Type | Validation | Description |
|-------|------|------------|-------------|
| type | PPEType | Required | Type of PPE |
| status | PPEStatus | Required | Current detection status |
| lastDetected | DateTime? | Optional | Last time this PPE was detected |

**PPEStatus Enum**:
```dart
enum PPEStatus {
  compliant,      // Correct PPE detected
  missing,        // Required PPE not detected
  notSuitable,    // Wrong type detected
  notRequired     // This PPE not required for worker
}
```

**Visual Mapping**:
- `compliant` -> Green checkmark icon
- `missing` -> Red cross icon
- `notSuitable` -> Orange warning icon
- `notRequired` -> Gray/hidden

**JSON Example**:
```json
{
  "type": "hardHat",
  "status": "compliant",
  "lastDetected": "2026-02-04T14:30:00Z"
}
```

---

### DetectionResult

Represents a single detection frame result from the AI service.

**Fields**:
| Field | Type | Validation | Description |
|-------|------|------------|-------------|
| frameId | String | Required | Unique frame identifier |
| detected | int | >= 0 | Total persons detected |
| compliant | int | >= 0, <= detected | Fully compliant persons |
| nonCompliant | int | >= 0 | Persons with violations |
| detections | List<PersonDetection> | Required | Individual detection details |

**PersonDetection (nested)**:
| Field | Type | Description |
|-------|------|-------------|
| workerId | String? | "Unknown" if not recognized |
| boundingBox | BoundingBox | Detection coordinates |
| ppeStatus | List<PPEItem> | Each PPE item status |
| overallStatus | ComplianceStatus | Overall compliance |
| confidence | double | Detection confidence 0-1 |

**ComplianceStatus Enum**:
```dart
enum ComplianceStatus {
  compliant,      // All required PPE present
  partial,        // Some PPE missing
  nonCompliant    // Critical PPE missing
}
```

**BoundingBox (nested)**:
| Field | Type | Description |
|-------|------|-------------|
| x | double | Left coordinate (0-1 relative) |
| y | double | Top coordinate (0-1 relative) |
| width | double | Width (0-1 relative) |
| height | double | Height (0-1 relative) |

**JSON Example**:
```json
{
  "frameId": "frame_1234567890",
  "detected": 3,
  "compliant": 1,
  "nonCompliant": 2,
  "detections": [
    {
      "workerId": "12345678",
      "boundingBox": {"x": 0.1, "y": 0.2, "width": 0.3, "height": 0.5},
      "ppeStatus": [
        {"type": "hardHat", "status": "compliant"},
        {"type": "vest", "status": "compliant"}
      ],
      "overallStatus": "compliant",
      "confidence": 0.95
    },
    {
      "workerId": "87654321",
      "boundingBox": {"x": 0.5, "y": 0.3, "width": 0.3, "height": 0.5},
      "ppeStatus": [
        {"type": "hardHat", "status": "missing"},
        {"type": "vest", "status": "compliant"}
      ],
      "overallStatus": "partial",
      "confidence": 0.87
    },
    {
      "workerId": null,
      "boundingBox": {"x": 0.7, "y": 0.1, "width": 0.25, "height": 0.4},
      "ppeStatus": [
        {"type": "hardHat", "status": "missing"},
        {"type": "vest", "status": "missing"}
      ],
      "overallStatus": "nonCompliant",
      "confidence": 0.72
    }
  ]
}
```

---

### AlertConfig

Represents user's notification preferences for a single alert type.

**Fields**:
| Field | Type | Validation | Description |
|-------|------|------------|-------------|
| alertType | AlertType | Required | Type of alert |
| enabled | bool | Required | Is alert active |
| deliveryMode | DeliveryMode | Required | How to deliver alert |
| priority | AlertPriority | Required | Alert importance |

**AlertType Enum**:
```dart
enum AlertType {
  ppeCompliance,
  proxWarning,
  stealthMode,
  zoneIncursion,
  safetyMetrics,
  systemStatus
}
```

**DeliveryMode Enum**:
```dart
enum DeliveryMode {
  audio,      // Sound only
  haptic,     // Vibration only
  dual        // Both sound and vibration
}
```

**AlertPriority Enum**:
```dart
enum AlertPriority {
  critical,   // Safety critical systems
  normal      // Intelligence feed
}
```

**JSON Example**:
```json
{
  "alertType": "ppeCompliance",
  "enabled": true,
  "deliveryMode": "dual",
  "priority": "critical"
}
```

---

### ReportData

Aggregated safety metrics for the reports screen.

**Fields**:
| Field | Type | Validation | Description |
|-------|------|------------|-------------|
| incidents | int | >= 0 | Total incidents in period |
| incidentsTrend | double | Percentage | Change from previous period |
| compliance | int | 0-100 | Compliance percentage |
| complianceTrend | double | Percentage | Change from previous period |
| dateRange | DateRange | Required | Report period |
| chartData | List<ChartDataPoint> | Required | Data for chart |
| lastUpdate | DateTime | Required | Last sync timestamp |

**DateRange (nested)**:
| Field | Type | Description |
|-------|------|-------------|
| start | DateTime | Period start |
| end | DateTime | Period end |

**ChartDataPoint (nested)**:
| Field | Type | Description |
|-------|------|-------------|
| label | String | X-axis label (date/time) |
| value | double | Y-axis value |
| series | String? | Series name (for multi-series) |

**JSON Example**:
```json
{
  "incidents": 12,
  "incidentsTrend": -5.0,
  "compliance": 98,
  "complianceTrend": 2.0,
  "dateRange": {
    "start": "2026-02-01T00:00:00Z",
    "end": "2026-02-04T23:59:59Z"
  },
  "chartData": [
    {"label": "Mon", "value": 96},
    {"label": "Tue", "value": 97},
    {"label": "Wed", "value": 94},
    {"label": "Thu", "value": 98}
  ],
  "lastUpdate": "2026-02-04T15:00:00Z"
}
```

---

### SystemStatus

Overall system health status for home dashboard.

**Fields**:
| Field | Type | Validation | Description |
|-------|------|------------|-------------|
| status | SystemHealth | Required | Overall system state |
| activeCameras | int | >= 0 | Number of active camera feeds |
| lastUpdate | DateTime | Required | Last status update timestamp |
| message | String | Required | Human-readable status message |

**SystemHealth Enum**:
```dart
enum SystemHealth {
  normal,        // All systems operational
  warning,       // Minor issues
  critical,      // Major issues
  offline        // System unavailable
}
```

**JSON Example**:
```json
{
  "status": "normal",
  "activeCameras": 4,
  "lastUpdate": "2026-02-04T15:30:00Z",
  "message": "All systems normal"
}
```

---

### UploadDetectionResult

Result of manual image upload for PPE analysis.

**Fields**:
| Field | Type | Validation | Description |
|-------|------|------------|-------------|
| imageId | String | Required | Uploaded image identifier |
| imageUrl | String | Required | URL to uploaded image |
| analysisStatus | AnalysisStatus | Required | Current analysis state |
| complianceScore | int? | 0-100 | Overall compliance percentage |
| ppeResults | List<PPEItem> | Required | Each PPE item result |
| analyzedAt | DateTime? | Optional | Analysis completion time |

**AnalysisStatus Enum**:
```dart
enum AnalysisStatus {
  pending,     // Waiting to be analyzed
  analyzing,   // Currently processing
  completed,   // Analysis complete
  failed       // Analysis failed
}
```

**JSON Example**:
```json
{
  "imageId": "upload_abc123",
  "imageUrl": "https://api.example.com/images/upload_abc123.jpg",
  "analysisStatus": "completed",
  "complianceScore": 98,
  "ppeResults": [
    {"type": "hardHat", "status": "compliant", "lastDetected": "2026-02-04T15:30:00Z"},
    {"type": "safetyGlasses", "status": "compliant", "lastDetected": "2026-02-04T15:30:00Z"},
    {"type": "earProtection", "status": "notSuitable", "lastDetected": null}
  ],
  "analyzedAt": "2026-02-04T15:30:15Z"
}
```

---

### UserSettings

User preferences and profile data.

**Fields**:
| Field | Type | Validation | Description |
|-------|------|------------|-------------|
| userId | String | Required | User identifier |
| fullName | String | Required | User's display name |
| title | String | Required | Job title |
| employeeId | String | Required | Employee ID |
| avatarUrl | String? | Optional | Profile image URL |
| language | String | Default: "en_US" | App language code |
| appearance | ThemeMode | Default: dark | Theme preference |
| hazardAlerts | bool | Default: true | Hazard alert toggle |
| safeZoneMonitoring | bool | Default: true | Zone monitoring toggle |
| biometricAuth | bool | Default: false | Biometric login enabled |
| isOnline | bool | Required | Current online status |

**ThemeMode Enum**:
```dart
enum ThemeMode {
  light,
  dark,
  system
}
```

**JSON Example**:
```json
{
  "userId": "user_123",
  "fullName": "Jane Doe",
  "title": "Senior Safety Inspector",
  "employeeId": "78910-SF",
  "avatarUrl": "https://api.example.com/avatars/user_123.jpg",
  "language": "en_US",
  "appearance": "dark",
  "hazardAlerts": true,
  "safeZoneMonitoring": true,
  "biometricAuth": false,
  "isOnline": true
}
```

---

## Entity Relationships

```
UserSettings 1----* AlertConfig
     |
     +----> can configure alerts

Worker 1----* PPEItem
     |
     +----> has required PPE list

Worker *----* DetectionResult
     |
     +----> appears in detection results

DetectionResult 1----* PersonDetection
     |
     +----> contains multiple person detections

PersonDetection *----* PPEItem
     |
     +----> has PPE status for each type
```

---

## Model Classes (Dart)

Each entity will have corresponding Dart model classes with:

1. **JSON Serialization**: `fromJson()` and `toJson()` methods
2. **CopyWith**: For immutable updates
3. **Equatable**: For value comparison in tests
4. **ToString**: For debugging

**Example Pattern**:
```dart
@immutable
class Worker extends Equatable {
  final String id;
  final String fullName;
  final String department;
  final String jobTitle;
  final List<PPEType> requiredPpe;
  final String? faceId;
  final DateTime createdAt;
  final int violationCount;

  const Worker({
    required this.id,
    required this.fullName,
    required this.department,
    required this.jobTitle,
    required this.requiredPpe,
    this.faceId,
    required this.createdAt,
    this.violationCount = 0,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      department: json['department'] as String,
      jobTitle: json['jobTitle'] as String,
      requiredPpe: (json['requiredPpe'] as List)
          .map((e) => PPEType.values.byName(e as String))
          .toList(),
      faceId: json['faceId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      violationCount: json['violationCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'department': department,
      'jobTitle': jobTitle,
      'requiredPpe': requiredPpe.map((e) => e.name).toList(),
      'faceId': faceId,
      'createdAt': createdAt.toIso8601String(),
      'violationCount': violationCount,
    };
  }

  Worker copyWith({
    String? id,
    String? fullName,
    String? department,
    String? jobTitle,
    List<PPEType>? requiredPpe,
    String? faceId,
    DateTime? createdAt,
    int? violationCount,
  }) {
    return Worker(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      department: department ?? this.department,
      jobTitle: jobTitle ?? this.jobTitle,
      requiredPpe: requiredPpe ?? this.requiredPpe,
      faceId: faceId ?? this.faceId,
      createdAt: createdAt ?? this.createdAt,
      violationCount: violationCount ?? this.violationCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        department,
        jobTitle,
        requiredPpe,
        faceId,
        createdAt,
        violationCount,
      ];

  @override
  String toString() =>
      'Worker(id: $id, name: $fullName, department: $department)';
}
```

---

## Validation Rules

### Worker Registration Form

| Field | Rule | Error Message |
|-------|------|---------------|
| Worker ID | Exactly 8 digits | "Worker ID must be 8 digits" |
| Full Name | 2-100 characters | "Name must be 2-100 characters" |
| Department | Must select from list | "Please select a department" |
| Job Title | Must select from list | "Please select a job title" |
| Required PPE | At least one selected | "At least one PPE item is required" |

### Alert Configuration

| Rule | Description |
|------|-------------|
| Critical alerts | Cannot be disabled (safety requirement) |
| Delivery mode | Must select one of: audio, haptic, dual |

### Image Upload

| Rule | Description |
|------|-------------|
| File size | Maximum 10MB |
| File type | JPG, PNG only |
| Resolution | Minimum 640x480 |
| Duration | Analysis timeout after 30 seconds |

---

## Local Storage Schema

### Hive Boxes

| Box Name | Type | Purpose |
|----------|------|---------|
| workers | Worker | Cached worker list |
| reports | ReportData | Cached report data |
| uploads | UploadDetectionResult | Recent upload results |

### SharedPreferences Keys

| Key | Type | Default | Purpose |
|-----|------|---------|---------|
| user_language | String | "en_US" | App language |
| app_theme | String | "dark" | Theme mode |
| hazard_alerts | bool | true | Hazard alert toggle |
| safe_zone_monitoring | bool | true | Zone monitoring toggle |
| biometric_auth | bool | false | Biometric login |
| user_id | String? | null | Current user ID |
| auth_token | String? | null | Authentication token (future) |

---

## Summary

This data model defines 8 core entities:
1. **Worker** - Personnel profiles
2. **PPEItem** - PPE status tracking
3. **DetectionResult** - Real-time detection data
4. **AlertConfig** - Notification preferences
5. **ReportData** - Analytics metrics
6. **SystemStatus** - System health
7. **UploadDetectionResult** - Manual analysis results
8. **UserSettings** - User profile and preferences

All entities include:
- Clear field types and validation rules
- JSON serialization examples
- Enum definitions for fixed values
- Entity relationship diagram
- Dart model class pattern
- Local storage schema
