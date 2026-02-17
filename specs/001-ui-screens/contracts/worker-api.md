# Worker API Contract

**Version**: 1.0.0
**Status**: Draft (stubs for UI implementation)
**Purpose**: Define API contracts for worker management endpoints

---

## GET /workers

Get list of all registered workers.

**Request**:
```http
GET /api/v1/workers
Authorization: Bearer {token}
```

**Query Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| page | int | No | Page number (default: 1) |
| limit | int | No | Items per page (default: 50) |
| department | string | No | Filter by department |
| search | string | No | Search by name or ID |

**Response** (200 OK):
```json
{
  "success": true,
  "data": [
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
  ],
  "pagination": {
    "page": 1,
    "limit": 50,
    "total": 150,
    "totalPages": 3
  }
}
```

**Error Responses**:
| Code | Description |
|------|-------------|
| 401 | Unauthorized - invalid or missing token |
| 403 | Forbidden - insufficient permissions |
| 500 | Internal server error |

---

## GET /workers/{id}

Get details of a specific worker.

**Request**:
```http
GET /api/v1/workers/{id}
Authorization: Bearer {token}
```

**Path Parameters**:
| Parameter | Type | Description |
|-----------|------|-------------|
| id | string | Worker ID (8 digits) |

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "id": "12345678",
    "fullName": "John Doe",
    "department": "Production",
    "jobTitle": "Machine Operator",
    "requiredPpe": ["hardHat", "safetyGlasses", "vest", "steelToedBoots"],
    "faceId": "face_template_123",
    "createdAt": "2026-02-04T10:00:00Z",
    "violationCount": 3,
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

**Error Responses**:
| Code | Description |
|------|-------------|
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Worker not found |
| 500 | Internal server error |

---

## POST /workers

Register a new worker.

**Request**:
```http
POST /api/v1/workers
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body**:
```json
{
  "id": "12345678",
  "fullName": "John Doe",
  "department": "Production",
  "jobTitle": "Machine Operator",
  "requiredPpe": ["hardHat", "safetyGlasses", "vest", "steelToedBoots"]
}
```

**Validation Rules**:
| Field | Rule |
|-------|------|
| id | Exactly 8 digits, unique |
| fullName | 2-100 characters |
| department | Must exist in predefined list |
| jobTitle | Must exist in predefined list |
| requiredPpe | At least one item, all valid PPEType values |

**Response** (201 Created):
```json
{
  "success": true,
  "data": {
    "id": "12345678",
    "fullName": "John Doe",
    "department": "Production",
    "jobTitle": "Machine Operator",
    "requiredPpe": ["hardHat", "safetyGlasses", "vest", "steelToedBoots"],
    "faceId": null,
    "createdAt": "2026-02-04T15:00:00Z",
    "violationCount": 0
  },
  "message": "Worker registered successfully"
}
```

**Error Responses**:
| Code | Description |
|------|-------------|
| 400 | Validation error - see response for details |
| 401 | Unauthorized |
| 403 | Forbidden |
| 409 | Worker ID already exists |
| 500 | Internal server error |

**Validation Error Response** (400):
```json
{
  "success": false,
  "error": "Validation failed",
  "details": [
    {
      "field": "id",
      "message": "Worker ID must be 8 digits"
    },
    {
      "field": "requiredPpe",
      "message": "At least one PPE item is required"
    }
  ]
}
```

---

## PUT /workers/{id}

Update an existing worker.

**Request**:
```http
PUT /api/v1/workers/{id}
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body** (all fields optional):
```json
{
  "fullName": "John Smith",
  "department": "Maintenance",
  "jobTitle": "Technician",
  "requiredPpe": ["hardHat", "safetyGlasses", "gloves"]
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "id": "12345678",
    "fullName": "John Smith",
    "department": "Maintenance",
    "jobTitle": "Technician",
    "requiredPpe": ["hardHat", "safetyGlasses", "gloves"],
    "faceId": "face_template_123",
    "createdAt": "2026-02-04T10:00:00Z",
    "violationCount": 3
  },
  "message": "Worker updated successfully"
}
```

**Error Responses**: Same as POST

---

## DELETE /workers/{id}

Delete a worker.

**Request**:
```http
DELETE /api/v1/workers/{id}
Authorization: Bearer {token}
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Worker deleted successfully"
}
```

**Error Responses**:
| Code | Description |
|------|-------------|
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Worker not found |
| 500 | Internal server error |

---

## GET /departments

Get list of available departments.

**Request**:
```http
GET /api/v1/departments
Authorization: Bearer {token}
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": [
    {"id": "prod", "name": "Production"},
    {"id": "maint", "name": "Maintenance"},
    {"id": "logistics", "name": "Logistics"},
    {"id": "quality", "name": "Quality Control"}
  ]
}
```

---

## GET /job-titles

Get list of available job titles.

**Request**:
```http
GET /api/v1/job-titles
Authorization: Bearer {token}
```

**Query Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| department | string | No | Filter by department |

**Response** (200 OK):
```json
{
  "success": true,
  "data": [
    {"id": "operator", "name": "Machine Operator"},
    {"id": "technician", "name": "Maintenance Technician"},
    {"id": "supervisor", "name": "Shift Supervisor"}
  ]
}
```
