# API Contracts Index

**Feature**: 001-ui-screens
**Version**: 1.0.0
**Status**: Draft (stubs for UI implementation)

## Overview

This directory contains API contract definitions for the industrial safety monitoring app. These contracts define the expected request/response formats for all backend interactions. During the UI implementation phase, these endpoints will be stubbed with mock data.

---

## Contracts by Category

### 1. [Worker API](worker-api.md)
Worker and personnel management endpoints.

- `GET /workers` - List all workers
- `GET /workers/{id}` - Get worker details
- `POST /workers` - Register new worker
- `PUT /workers/{id}` - Update worker
- `DELETE /workers/{id}` - Delete worker
- `GET /departments` - List departments
- `GET /job-titles` - List job titles

### 2. [Detection API](detection-api.md)
Real-time PPE detection and image upload endpoints.

- `WS /ws/detection/{cameraId}` - Real-time detection stream
- `POST /detection/upload` - Upload image for analysis
- `GET /detection/upload/{imageId}` - Get analysis result
- `GET /detection/status` - Get system status
- `GET /cameras` - List available cameras
- `POST /cameras/{cameraId}/control` - Control camera

### 3. [Reports API](reports-api.md)
Safety reports and analytics endpoints.

- `GET /reports/summary` - Get metrics summary
- `GET /reports/chart` - Get chart data
- `GET /reports/violations` - Get violation records
- `GET /reports/worker/{workerId}` - Get worker report
- `POST /reports/export` - Export report
- `GET /reports/export/{exportId}` - Check export status

### 4. [Alerts API](alerts-api.md)
Alert configuration and notification endpoints.

- `GET /alerts/config` - Get alert configuration
- `PUT /alerts/config` - Update alert configuration
- `GET /alerts/history` - Get alert history
- `PUT /alerts/{alertId}/read` - Mark alert as read
- `PUT /alerts/read-all` - Mark all as read
- `DELETE /alerts/{alertId}` - Delete alert
- `POST /alerts/test` - Send test alert
- `WS /ws/notifications` - Real-time notifications stream

### 5. [Settings API](settings-api.md)
User settings and profile management endpoints.

- `GET /settings` - Get app settings
- `PUT /settings` - Update app settings
- `GET /profile` - Get user profile
- `PUT /profile` - Update user profile
- `POST /profile/avatar` - Upload avatar
- `GET /languages` - Get supported languages
- `POST /auth/logout` - Logout user
- `POST /auth/biometric/register` - Register biometric (future)

### 6. [Instructions API](instructions-api.md)
App usage instructions and help content endpoints.

- `GET /instructions/categories` - Get content categories
- `GET /instructions/tutorials` - Get tutorial list
- `GET /instructions/tutorials/{tutorialId}` - Get tutorial content
- `GET /instructions/faq` - Get FAQs
- `POST /instructions/faq/{faqId}/helpful` - Mark FAQ feedback
- `GET /instructions/search` - Search content
- `GET /instructions/videos` - Get tutorial videos

---

## Common Patterns

### Authentication

All API requests require authentication via Bearer token:

```http
Authorization: Bearer {token}
```

### Response Format

Success responses follow this pattern:

```json
{
  "success": true,
  "data": { ... },
  "message": "Optional success message"
}
```

Error responses follow this pattern:

```json
{
  "success": false,
  "error": "Error type",
  "message": "Human-readable error message",
  "details": { ... }
}
```

### Error Codes

| Code | Description |
|------|-------------|
| 200 | OK - Request successful |
| 201 | Created - Resource created |
| 202 | Accepted - Request queued/processing |
| 400 | Bad Request - Invalid input |
| 401 | Unauthorized - Invalid/missing token |
| 403 | Forbidden - Insufficient permissions |
| 404 | Not Found - Resource doesn't exist |
| 409 | Conflict - Resource already exists |
| 413 | Payload Too Large - File size exceeded |
| 500 | Internal Server Error |

### Pagination

List endpoints support pagination:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| page | int | 1 | Page number |
| limit | int | 20/50 | Items per page |

Response includes pagination metadata:

```json
{
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "totalPages": 8
  }
}
```

---

## Mock Implementation

For UI development, all endpoints will be stubbed using mock services. The following pattern will be used:

```dart
class WorkerApiStub implements WorkerApi {
  @override
  Future<List<Worker>> getWorkers() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock data
    return [
      Worker(
        id: '12345678',
        fullName: 'John Doe',
        department: 'Production',
        jobTitle: 'Machine Operator',
        requiredPpe: [PPEType.hardHat, PPEType.safetyGlasses],
        createdAt: DateTime.now(),
      ),
      // ... more mock workers
    ];
  }
}
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-02-04 | Initial contract definitions for UI phase |
