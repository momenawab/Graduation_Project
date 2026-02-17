# Reports API Contract

**Version**: 1.0.0
**Status**: Draft (stubs for UI implementation)
**Purpose**: Define API contracts for safety reports and analytics

---

## GET /reports/summary

Get safety metrics summary for dashboard.

**Request**:
```http
GET /api/v1/reports/summary
Authorization: Bearer {token}
```

**Query Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| dateRange | string | No | Period: today, week, month (default: week) |
| location | string | No | Filter by location |

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "incidents": 12,
    "incidentsTrend": -5.0,
    "compliance": 98,
    "complianceTrend": 2.0,
    "dateRange": {
      "start": "2026-02-01T00:00:00Z",
      "end": "2026-02-04T23:59:59Z"
    },
    "lastUpdate": "2026-02-04T15:00:00Z"
  }
}
```

---

## GET /reports/chart

Get chart data for visualization.

**Request**:
```http
GET /api/v1/reports/chart
Authorization: Bearer {token}
```

**Query Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| type | string | No | Chart type: incidents, compliance, violations (default: incidents) |
| period | string | No | Time grouping: hour, day, week (default: day) |
| startDate | string | No | ISO 8601 date |
| endDate | string | No | ISO 8601 date |

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "chartType": "incidents",
    "period": "day",
    "chartData": [
      {"label": "Mon", "value": 96},
      {"label": "Tue", "value": 97},
      {"label": "Wed", "value": 94},
      {"label": "Thu", "value": 98}
    ],
    "metadata": {
      "startDate": "2026-02-01T00:00:00Z",
      "endDate": "2026-02-04T23:59:59Z",
      "totalDataPoints": 4
    }
  }
}
```

---

## GET /reports/violations

Get detailed violation records.

**Request**:
```http
GET /api/v1/reports/violations
Authorization: Bearer {token}
```

**Query Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| page | int | No | Page number (default: 1) |
| limit | int | No | Items per page (default: 20) |
| workerId | string | No | Filter by worker |
| startDate | string | No | ISO 8601 date |
| endDate | string | No | ISO 8601 date |
| ppeType | string | No | Filter by PPE type |

**Response** (200 OK):
```json
{
  "success": true,
  "data": [
    {
      "violationId": "vio_001",
      "timestamp": "2026-02-04T09:30:00Z",
      "workerId": "87654321",
      "workerName": "Jane Smith",
      "department": "Production",
      "location": "Zone A",
      "missingPpe": ["hardHat"],
      "imageUrl": "https://api.example.com/violations/vio_001.jpg",
      "resolved": false
    },
    {
      "violationId": "vio_002",
      "timestamp": "2026-02-04T10:15:00Z",
      "workerId": "12345678",
      "workerName": "John Doe",
      "department": "Maintenance",
      "location": "Zone B",
      "missingPpe": ["vest", "safetyGlasses"],
      "imageUrl": "https://api.example.com/violations/vio_002.jpg",
      "resolved": true
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 45,
    "totalPages": 3
  }
}
```

---

## GET /reports/worker/{workerId}

Get violation report for specific worker.

**Request**:
```http
GET /api/v1/reports/worker/{workerId}
Authorization: Bearer {token}
```

**Path Parameters**:
| Parameter | Type | Description |
|-----------|------|-------------|
| workerId | string | Worker ID |

**Query Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| startDate | string | No | ISO 8601 date |
| endDate | string | No | ISO 8601 date |

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "workerId": "12345678",
    "workerName": "John Doe",
    "department": "Maintenance",
    "totalViolations": 15,
    "violationsByPpe": {
      "hardHat": 5,
      "vest": 8,
      "safetyGlasses": 2
    },
    "violationTrend": "decreasing",
    "recentViolations": [
      {
        "timestamp": "2026-02-04T09:30:00Z",
        "missingPpe": ["hardHat"],
        "location": "Zone A"
      }
    ]
  }
}
```

---

## POST /reports/export

Export report data as file.

**Request**:
```http
POST /api/v1/reports/export
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body**:
```json
{
  "format": "pdf",
  "dateRange": {
    "start": "2026-02-01T00:00:00Z",
    "end": "2026-02-04T23:59:59Z"
  },
  "includeCharts": true,
  "includeImages": false
}
```

**Formats**:
| Format | Description |
|--------|-------------|
| pdf | PDF document |
| csv | CSV spreadsheet |
| json | Raw JSON data |

**Response** (202 Accepted):
```json
{
  "success": true,
  "data": {
    "exportId": "exp_abc123",
    "status": "processing",
    "estimatedTime": 5
  },
  "message": "Export job started"
}
```

**Response** (when ready):
```json
{
  "success": true,
  "data": {
    "exportId": "exp_abc123",
    "status": "completed",
    "downloadUrl": "https://api.example.com/exports/exp_abc123.pdf",
    "expiresAt": "2026-02-05T15:00:00Z"
  }
}
```

---

## GET /reports/export/{exportId}

Check export job status.

**Request**:
```http
GET /api/v1/reports/export/{exportId}
Authorization: Bearer {token}
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "exportId": "exp_abc123",
    "status": "processing",
    "progress": 60
  }
}
```

**Status Values**:
| Status | Description |
|--------|-------------|
| pending | Job queued |
| processing | In progress |
| completed | Ready for download |
| failed | Job failed |
