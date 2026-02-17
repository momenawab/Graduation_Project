# Alerts API Contract

**Version**: 1.0.0
**Status**: Draft (stubs for UI implementation)
**Purpose**: Define API contracts for alert configuration and notifications

---

## GET /alerts/config

Get user's alert configuration.

**Request**:
```http
GET /api/v1/alerts/config
Authorization: Bearer {token}
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "safetyCritical": [
      {
        "alertType": "ppeCompliance",
        "enabled": true,
        "deliveryMode": "dual",
        "priority": "critical"
      },
      {
        "alertType": "proxWarning",
        "enabled": true,
        "deliveryMode": "haptic",
        "priority": "critical"
      },
      {
        "alertType": "zoneIncursion",
        "enabled": false,
        "deliveryMode": "audio",
        "priority": "critical"
      },
      {
        "alertType": "stealthMode",
        "enabled": false,
        "deliveryMode": "audio",
        "priority": "critical"
      }
    ],
    "intelligenceFeed": [
      {
        "alertType": "safetyMetrics",
        "enabled": false,
        "deliveryMode": "audio",
        "priority": "normal"
      },
      {
        "alertType": "systemStatus",
        "enabled": false,
        "deliveryMode": "audio",
        "priority": "normal"
      }
    ]
  }
}
```

---

## PUT /alerts/config

Update user's alert configuration.

**Request**:
```http
PUT /api/v1/alerts/config
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body**:
```json
{
  "alerts": [
    {
      "alertType": "ppeCompliance",
      "enabled": true,
      "deliveryMode": "dual"
    },
    {
      "alertType": "proxWarning",
      "enabled": true,
      "deliveryMode": "haptic"
    },
    {
      "alertType": "zoneIncursion",
      "enabled": false,
      "deliveryMode": "audio"
    },
    {
      "alertType": "stealthMode",
      "enabled": false,
      "deliveryMode": "audio"
    },
    {
      "alertType": "safetyMetrics",
      "enabled": true,
      "deliveryMode": "audio"
    },
    {
      "alertType": "systemStatus",
      "enabled": false,
      "deliveryMode": "audio"
    }
  ]
}
```

**Delivery Modes**:
| Mode | Description |
|------|-------------|
| audio | Sound notification only |
| haptic | Vibration only |
| dual | Both sound and vibration |

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "updatedAt": "2026-02-04T15:30:00Z",
    "alerts": [
      {
        "alertType": "ppeCompliance",
        "enabled": true,
        "deliveryMode": "dual",
        "priority": "critical"
      }
    ]
  },
  "message": "Alert configuration updated"
}
```

**Error Responses**:
| Code | Description |
|------|-------------|
| 400 | Invalid delivery mode or alert type |
| 401 | Unauthorized |
| 403 | Cannot disable critical alerts |

---

## GET /alerts/history

Get user's alert history.

**Request**:
```http
GET /api/v1/alerts/history
Authorization: Bearer {token}
```

**Query Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| page | int | No | Page number (default: 1) |
| limit | int | No | Items per page (default: 20) |
| alertType | string | No | Filter by alert type |
| read | boolean | No | Filter by read status |

**Response** (200 OK):
```json
{
  "success": true,
  "data": [
    {
      "alertId": "alert_001",
      "alertType": "ppeCompliance",
      "severity": "critical",
      "title": "PPE Violation Detected",
      "message": "Hardhat not detected on Worker 87654321",
      "workerId": "87654321",
      "timestamp": "2026-02-04T15:25:00Z",
      "read": false,
      "resolved": false
    },
    {
      "alertId": "alert_002",
      "alertType": "proxWarning",
      "severity": "warning",
      "title": "Proximity Warning",
      "message": "Worker 12345678 too close to machinery",
      "workerId": "12345678",
      "timestamp": "2026-02-04T15:20:00Z",
      "read": true,
      "resolved": true
    },
    {
      "alertId": "alert_003",
      "alertType": "safetyMetrics",
      "severity": "info",
      "title": "Daily Safety Report",
      "message": "Compliance score: 98% for today",
      "timestamp": "2026-02-04T08:00:00Z",
      "read": true,
      "resolved": true
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 85,
    "totalPages": 5
  },
  "unreadCount": 12
}
```

---

## PUT /alerts/{alertId}/read

Mark alert as read.

**Request**:
```http
PUT /api/v1/alerts/{alertId}/read
Authorization: Bearer {token}
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Alert marked as read"
}
```

---

## PUT /alerts/read-all

Mark all alerts as read.

**Request**:
```http
PUT /api/v1/alerts/read-all
Authorization: Bearer {token}
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "markedCount": 12
  },
  "message": "All alerts marked as read"
}
```

---

## DELETE /alerts/{alertId}

Delete/dismiss an alert.

**Request**:
```http
DELETE /api/v1/alerts/{alertId}
Authorization: Bearer {token}
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Alert deleted"
}
```

---

## POST /alerts/test

Send test alert to verify settings.

**Request**:
```http
POST /api/v1/alerts/test
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body**:
```json
{
  "alertType": "ppeCompliance"
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Test alert sent"
}
```

**Note**: The actual test notification will be pushed to the client via WebSocket or push notification.

---

## WebSocket: /ws/notifications

Real-time alert notifications stream.

**Connection**:
```websocket
WS /api/v1/ws/notifications?token={token}
```

**Server → Client Messages** (New Alert):
```json
{
  "type": "alert",
  "alertId": "alert_004",
  "alertType": "ppeCompliance",
  "severity": "critical",
  "title": "PPE Violation Detected",
  "message": "Hardhat not detected on Worker 87654321",
  "workerId": "87654321",
  "timestamp": "2026-02-04T15:30:00Z",
  "sound": "critical_alert.mp3",
  "vibrate": true
}
```

**Server → Client Messages** (Alert Resolved):
```json
{
  "type": "resolved",
  "alertId": "alert_003",
  "timestamp": "2026-02-04T15:30:00Z"
}
```

**Server → Client Messages** (Heartbeat):
```json
{
  "type": "ping",
  "timestamp": "2026-02-04T15:30:00Z"
}
```

**Client → Server Messages** (Pong):
```json
{
  "type": "pong"
}
```
