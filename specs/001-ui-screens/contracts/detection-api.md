# Detection API Contract

**Version**: 1.0.0
**Status**: Draft (stubs for UI implementation)
**Purpose**: Define API contracts for real-time PPE detection and image upload

---

## WebSocket: /ws/detection/{cameraId}

Real-time detection stream for camera feed.

**Connection**:
```websocket
WS /api/v1/ws/detection/{cameraId}
```

**Path Parameters**:
| Parameter | Type | Description |
|-----------|------|-------------|
| cameraId | string | Camera identifier |

**Query Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| token | string | Yes | Authentication token |

**Server → Client Messages** (Detection Frame):
```json
{
  "type": "detection",
  "frameId": "frame_1234567890",
  "timestamp": "2026-02-04T15:30:00Z",
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

**Server → Client Messages** (Alert):
```json
{
  "type": "alert",
  "alertId": "alert_abc123",
  "timestamp": "2026-02-04T15:30:05Z",
  "severity": "critical",
  "title": "PPE Violation Detected",
  "message": "Hardhat not detected on Worker 87654321",
  "workerId": "87654321",
  "missingPpe": ["hardHat"]
}
```

**Server → Client Messages** (Status):
```json
{
  "type": "status",
  "status": "connected",
  "message": "Detection stream active"
}
```

**Server → Client Messages** (Error):
```json
{
  "type": "error",
  "code": "CAMERA_OFFLINE",
  "message": "Camera is currently offline"
}
```

**Client → Server Messages** (Control):
```json
{
  "action": "start"
}
```

```json
{
  "action": "stop"
}
```

```json
{
  "action": "snapshot"
}
```

**Error Codes**:
| Code | Description |
|------|-------------|
| UNAUTHORIZED | Invalid or missing token |
| CAMERA_NOT_FOUND | Camera does not exist |
| CAMERA_OFFLINE | Camera is not available |
| RATE_LIMITED | Too many connections |

---

## POST /detection/upload

Upload an image for PPE analysis.

**Request**:
```http
POST /api/v1/detection/upload
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**Request Body** (multipart/form-data):
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| image | file | Yes | Image file (JPG/PNG, max 10MB) |
| cameraId | string | No | Source camera identifier |

**Response** (202 Accepted):
```json
{
  "success": true,
  "data": {
    "imageId": "upload_abc123",
    "imageUrl": "https://api.example.com/images/upload_abc123.jpg",
    "analysisStatus": "pending"
  },
  "message": "Image uploaded successfully. Analysis in progress."
}
```

**Error Responses**:
| Code | Description |
|------|-------------|
| 400 | Invalid file type or size |
| 401 | Unauthorized |
| 413 | File too large |
| 500 | Upload failed |

---

## GET /detection/upload/{imageId}

Get analysis result for uploaded image.

**Request**:
```http
GET /api/v1/detection/upload/{imageId}
Authorization: Bearer {token}
```

**Path Parameters**:
| Parameter | Type | Description |
|-----------|------|-------------|
| imageId | string | Upload image ID |

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
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
}
```

**Response** (202 Accepted) - Still analyzing:
```json
{
  "success": true,
  "data": {
    "imageId": "upload_abc123",
    "imageUrl": "https://api.example.com/images/upload_abc123.jpg",
    "analysisStatus": "analyzing"
  }
}
```

**Response** (500) - Analysis failed:
```json
{
  "success": false,
  "error": "Analysis failed",
  "data": {
    "imageId": "upload_abc123",
    "imageUrl": "https://api.example.com/images/upload_abc123.jpg",
    "analysisStatus": "failed",
    "errorMessage": "No persons detected in image"
  }
}
```

**Error Responses**:
| Code | Description |
|------|-------------|
| 401 | Unauthorized |
| 404 | Image not found |
| 500 | Internal server error |

---

## GET /detection/status

Get current system detection status.

**Request**:
```http
GET /api/v1/detection/status
Authorization: Bearer {token}
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "status": "normal",
    "activeCameras": 4,
    "lastUpdate": "2026-02-04T15:30:00Z",
    "message": "All systems normal"
  }
}
```

---

## GET /cameras

Get list of available cameras.

**Request**:
```http
GET /api/v1/cameras
Authorization: Bearer {token}
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": [
    {
      "id": "cam_001",
      "name": "Production Zone A",
      "location": "Building 1, Floor 2",
      "status": "online",
      "resolution": "1920x1080",
      "fps": 30
    },
    {
      "id": "cam_002",
      "name": "Loading Dock",
      "location": "Building 1, Ground Floor",
      "status": "offline",
      "resolution": "1280x720",
      "fps": 15
    }
  ]
}
```

---

## POST /cameras/{cameraId}/control

Send control commands to a camera.

**Request**:
```http
POST /api/v1/cameras/{cameraId}/control
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body**:
```json
{
  "action": "start",
  "options": {
    "resolution": "1080p",
    "fps": 30
  }
}
```

**Actions**:
| Action | Description |
|--------|-------------|
| start | Start camera stream |
| stop | Stop camera stream |
| snapshot | Capture single frame |

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Camera started successfully"
}
```

**Error Responses**:
| Code | Description |
|------|-------------|
| 400 | Invalid action |
| 401 | Unauthorized |
| 403 | Insufficient permissions |
| 404 | Camera not found |
| 503 | Camera unavailable |
