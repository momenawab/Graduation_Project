# Settings API Contract

**Version**: 1.0.0
**Status**: Draft (stubs for UI implementation)
**Purpose**: Define API contracts for user settings and profile management

---

## GET /settings

Get user's app settings.

**Request**:
```http
GET /api/v1/settings
Authorization: Bearer {token}
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "userId": "user_123",
    "language": "en_US",
    "appearance": "dark",
    "hazardAlerts": true,
    "safeZoneMonitoring": true,
    "biometricAuth": false,
    "notifications": {
      "enabled": true,
      "quietHoursStart": "22:00",
      "quietHoursEnd": "06:00"
    }
  }
}
```

---

## PUT /settings

Update user's app settings.

**Request**:
```http
PUT /api/v1/settings
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body** (all fields optional):
```json
{
  "language": "en_US",
  "appearance": "dark",
  "hazardAlerts": true,
  "safeZoneMonitoring": true,
  "biometricAuth": false,
  "notifications": {
    "enabled": true,
    "quietHoursStart": "22:00",
    "quietHoursEnd": "06:00"
  }
}
```

**Field Validation**:
| Field | Type | Valid Values |
|-------|------|--------------|
| language | string | en_US, ar_SA, etc. |
| appearance | string | light, dark, system |
| hazardAlerts | boolean | true, false |
| safeZoneMonitoring | boolean | true, false |
| biometricAuth | boolean | true, false |
| notifications.enabled | boolean | true, false |
| notifications.quietHoursStart | string | HH:MM format |
| notifications.quietHoursEnd | string | HH:MM format |

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "userId": "user_123",
    "language": "en_US",
    "appearance": "dark",
    "hazardAlerts": true,
    "safeZoneMonitoring": true,
    "biometricAuth": false,
    "notifications": {
      "enabled": true,
      "quietHoursStart": "22:00",
      "quietHoursEnd": "06:00"
    }
  },
  "message": "Settings updated"
}
```

---

## GET /profile

Get user's profile information.

**Request**:
```http
GET /api/v1/profile
Authorization: Bearer {token}
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "userId": "user_123",
    "fullName": "Jane Doe",
    "title": "Senior Safety Inspector",
    "employeeId": "78910-SF",
    "avatarUrl": "https://api.example.com/avatars/user_123.jpg",
    "email": "jane.doe@example.com",
    "phoneNumber": "+1234567890",
    "department": "Safety",
    "joinDate": "2025-01-15T00:00:00Z",
    "isOnline": true
  }
}
```

---

## PUT /profile

Update user's profile.

**Request**:
```http
PUT /api/v1/profile
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body** (all fields optional):
```json
{
  "fullName": "Jane Smith",
  "title": "Safety Manager",
  "phoneNumber": "+0987654321"
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "userId": "user_123",
    "fullName": "Jane Smith",
    "title": "Safety Manager",
    "employeeId": "78910-SF",
    "avatarUrl": "https://api.example.com/avatars/user_123.jpg",
    "email": "jane.doe@example.com",
    "phoneNumber": "+0987654321",
    "department": "Safety",
    "joinDate": "2025-01-15T00:00:00Z",
    "isOnline": true
  },
  "message": "Profile updated"
}
```

---

## POST /profile/avatar

Upload profile avatar image.

**Request**:
```http
POST /api/v1/profile/avatar
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**Request Body** (multipart/form-data):
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| avatar | file | Yes | Image file (JPG/PNG, max 5MB) |

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "avatarUrl": "https://api.example.com/avatars/user_123_new.jpg"
  },
  "message": "Avatar updated"
}
```

---

## GET /languages

Get list of supported languages.

**Request**:
```http
GET /api/v1/languages
Authorization: Bearer {token}
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": [
    {
      "code": "en_US",
      "name": "English (US)",
      "nativeName": "English"
    },
    {
      "code": "ar_SA",
      "name": "Arabic (Saudi Arabia)",
      "nativeName": "العربية"
    },
    {
      "code": "es_ES",
      "name": "Spanish (Spain)",
      "nativeName": "Español"
    }
  ]
}
```

---

## POST /auth/logout

Log out user and invalidate token.

**Request**:
```http
POST /api/v1/auth/logout
Authorization: Bearer {token}
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

**Note**: Client should clear locally stored tokens and settings cache.

---

## POST /auth/biometric/register

Register biometric authentication (future feature).

**Request**:
```http
POST /api/v1/auth/biometric/register
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body**:
```json
{
  "biometricType": "fingerprint",
  "deviceName": "iPhone 14 Pro"
}
```

**Biometric Types**:
| Type | Description |
|------|-------------|
| fingerprint | Fingerprint scanner |
| face | Face recognition |
| iris | Iris scanner |

**Response** (201 Created):
```json
{
  "success": true,
  "data": {
    "biometricId": "bio_123",
    "registeredAt": "2026-02-04T15:30:00Z"
  },
  "message": "Biometric authentication registered"
}
```

**Error Responses**:
| Code | Description |
|------|-------------|
| 400 | Device does not support biometric |
| 401 | Unauthorized |
| 501 | Not implemented (feature deferred) |
