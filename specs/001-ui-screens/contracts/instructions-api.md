# Instructions/Help API Contract

**Version**: 1.0.0
**Status**: Draft (stubs for UI implementation)
**Purpose**: Define API contracts for app usage instructions and help content

---

## GET /instructions/categories

Get available instruction categories.

**Request**:
```http
GET /api/v1/instructions/categories
Authorization: Bearer {token}
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": [
    {
      "id": "getting-started",
      "name": "Getting Started",
      "icon": "rocket_launch",
      "order": 1
    },
    {
      "id": "ai-detection",
      "name": "AI Detection",
      "icon": "psychology",
      "order": 2
    },
    {
      "id": "safety-alerts",
      "name": "Safety Alerts",
      "icon": "notifications",
      "order": 3
    }
  ]
}
```

---

## GET /instructions/tutorials

Get list of tutorials.

**Request**:
```http
GET /api/v1/instructions/tutorials
Authorization: Bearer {token}
```

**Query Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| category | string | No | Filter by category ID |
| search | string | No | Search in title/content |

**Response** (200 OK):
```json
{
  "success": true,
  "data": [
    {
      "id": "tut_001",
      "categoryId": "getting-started",
      "title": "Activating AI Scanning",
      "description": "Learn to deploy real-time equipment verification",
      "icon": "360",
      "iconColor": "#2196F3",
      "duration": 5,
      "order": 1
    },
    {
      "id": "tut_002",
      "categoryId": "ai-detection",
      "title": "Hazard Identification",
      "description": "Interpret automated safety risk alerts",
      "icon": "warning",
      "iconColor": "#FF9800",
      "duration": 8,
      "order": 1
    },
    {
      "id": "tut_003",
      "categoryId": "safety-alerts",
      "title": "Safety Reports",
      "description": "Documentation workflow for site incidents",
      "icon": "description",
      "iconColor": "#4CAF50",
      "duration": 6,
      "order": 1
    },
    {
      "id": "tut_004",
      "categoryId": "getting-started",
      "title": "Worker Profiles",
      "description": "Manage certifications and shift preferences",
      "icon": "person",
      "iconColor": "#9C27B0",
      "duration": 4,
      "order": 2
    }
  ]
}
```

---

## GET /instructions/tutorials/{tutorialId}

Get detailed tutorial content.

**Request**:
```http
GET /api/v1/instructions/tutorials/{tutorialId}
Authorization: Bearer {token}
```

**Path Parameters**:
| Parameter | Type | Description |
|-----------|------|-------------|
| tutorialId | string | Tutorial ID |

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "id": "tut_001",
    "categoryId": "getting-started",
    "title": "Activating AI Scanning",
    "description": "Learn to deploy real-time equipment verification",
    "duration": 5,
    "content": [
      {
        "type": "text",
        "text": "AI scanning continuously monitors the camera feed for PPE compliance. Here's how to activate it:"
      },
      {
        "type": "step",
        "stepNumber": 1,
        "title": "Open Monitoring Screen",
        "text": "Tap the 'Monitoring' card on the home screen."
      },
      {
        "type": "step",
        "stepNumber": 2,
        "title": "Select Camera",
        "text": "Choose the camera you want to monitor from the dropdown."
      },
      {
        "type": "step",
        "stepNumber": 3,
        "title": "Start Scanning",
        "text": "Tap the green 'Start' button to begin AI scanning."
      },
      {
        "type": "tip",
        "text": "Make sure the camera has a clear view of the area for best results."
      }
    ],
    "relatedTutorials": ["tut_002", "tut_003"]
  }
}
```

**Content Types**:
| Type | Fields | Description |
|------|--------|-------------|
| text | text | Plain text paragraph |
| step | stepNumber, title, text | Numbered step |
| tip | text | Highlighted tip box |
| image | imageUrl, caption | Tutorial image |
| video | videoUrl, thumbnailUrl | Tutorial video |

---

## GET /instructions/faq

Get frequently asked questions.

**Request**:
```http
GET /api/v1/instructions/faq
Authorization: Bearer {token}
```

**Query Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| category | string | No | Filter by category |
| search | string | No | Search in questions/answers |

**Response** (200 OK):
```json
{
  "success": true,
  "data": [
    {
      "id": "faq_001",
      "question": "AI detection fails in low light?",
      "answer": "Ensure adequate lighting in the monitored area. The AI requires minimum 100 lux for reliable detection. Consider adding artificial lighting if needed.",
      "categoryId": "ai-detection",
      "helpful": 42,
      "notHelpful": 3
    },
    {
      "id": "faq_002",
      "question": "Syncing report data?",
      "answer": "Reports sync automatically every 5 minutes when connected. Pull down on the reports screen to force an immediate sync.",
      "categoryId": "safety-alerts",
      "helpful": 28,
      "notHelpful": 5
    }
  ]
}
```

---

## POST /instructions/faq/{faqId}/helpful

Mark FAQ as helpful or not.

**Request**:
```http
POST /api/v1/instructions/faq/{faqId}/helpful
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body**:
```json
{
  "helpful": true
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Feedback recorded"
}
```

---

## GET /instructions/search

Search all instruction content.

**Request**:
```http
GET /api/v1/instructions/search?q={query}
Authorization: Bearer {token}
```

**Query Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| q | string | Yes | Search query |
| type | string | No | Filter by type: tutorials, faq, all |

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "query": "camera",
    "results": [
      {
        "type": "tutorial",
        "id": "tut_001",
        "title": "Activating AI Scanning",
        "snippet": "...Select Camera from the dropdown..."
      },
      {
        "type": "faq",
        "id": "faq_003",
        "question": "How to add a new camera?",
        "snippet": "Navigate to Settings > Cameras and tap Add..."
      }
    ],
    "total": 2
  }
}
```

---

## GET /instructions/videos

Get tutorial videos (if available).

**Request**:
```http
GET /api/v1/instructions/videos
Authorization: Bearer {token}
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": [
    {
      "id": "vid_001",
      "title": "App Overview",
      "description": "Complete tour of the SafeSight app",
      "thumbnailUrl": "https://cdn.example.com/thumbs/vid_001.jpg",
      "videoUrl": "https://cdn.example.com/videos/vid_001.m3u8",
      "duration": 180,
      "views": 1250
    }
  ]
}
```

**Note**: Video content is optional and may not be available in all deployments.
