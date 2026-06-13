<!--
================================================================================
SYNC IMPACT REPORT
================================================================================
Version Change: [TEMPLATE] → 1.0.0 (Initial Ratification)

Modified Principles: N/A (initial creation)

Added Sections:
  - Core Principles (5 principles defined)
  - Flutter Architecture Standards
  - Development Workflow
  - Governance

Removed Sections: N/A

Templates Status:
  - .specify/templates/plan-template.md: ✅ Reviewed - Constitution Check section aligned
  - .specify/templates/spec-template.md: ✅ Reviewed - User story approach validated
  - .specify/templates/tasks-template.md: ✅ Reviewed - Task categorization aligned
  - .specify/templates/checklist-template.md: ⚠ Pending review
  - .specify/templates/agent-file-template.md: ⚠ Pending review

Follow-up TODOs: None

================================================================================
-->

# SafeSight Constitution

## Core Principles

### I. Clean Architecture

The application MUST follow Clean Architecture with clear separation of concerns:

- **UI Layer**: Pure Flutter widgets with no business logic
- **Controller Layer**: GetX controllers managing state and coordination
- **Service Layer**: API communication, WebSocket handling, data transformation
- **Model Layer**: Data models with JSON serialization

**Rationale**: Clean separation enables independent testing, swapping implementations (e.g., mock vs real API), and maintaining code as the project grows. Each layer has a single responsibility.

### II. API-First Design

Every screen MUST be designed API-ready before implementation begins:

- **API Endpoint**: Define expected REST or WebSocket endpoint path
- **Request Structure**: JSON schema for all parameters
- **Response Structure**: JSON schema for all response data
- **Error States**: Define all possible error codes and user-facing messages
- **Loading States**: Define skeleton/placeholder UI for loading

**Rationale**: Frontend and backend can be developed in parallel. Clear contracts prevent integration issues and enable mock-driven development.

### III. Realtime-Ready Architecture

The app MUST be architected to support realtime video stream analysis:

- **Frame-by-Frame Processing**: UI must update continuously as detection results arrive
- **Virtual Camera Support**: Pre-recorded video must simulate live camera feed
- **Stream Integration**: WebSocket or polling mechanism for periodic detection updates
- **State Caching**: Latest detection state must persist between streams

**Rationale**: Industrial safety requires immediate feedback. The architecture must handle continuous data streams without blocking the UI thread.

### IV. Visual Clarity & Industrial Standards

UI must prioritize readability and professional industrial aesthetics:

- **Color Coding**: Green (compliant), Red (violation), Orange (warning)
- **Status Icons**: Clear check/cross/warning symbols for PPE status
- **High Contrast**: Ensure visibility in various lighting conditions
- **Minimal Animation**: Focus on function over decorative effects
- **Human-Readable Output**: Detection results must be instantly understandable

**Rationale**: Industrial environments require quick comprehension. Safety-critical information must be unambiguous.

### V. Role-Based Access Control

The app MUST enforce clear role separation:

- **Admin Role**: Full access to realtime monitoring, alerts history, violation analytics
- **User Role**: Limited to personal alerts and own PPE violation count
- **Data Isolation**: Users cannot access other users' data
- **Role Verification**: Backend MUST validate role on every request

**Rationale**: Privacy and data security are critical. Different users have different needs and permissions.

## Flutter Architecture Standards

### State Management

- **GetX**: MUST be used for all state management
- **Reactive Variables**: Use `.obs` for reactive state
- **Dependency Injection**: Use GetX binding for controllers/services

### Project Structure

```
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   └── utils/
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
│       ├── api/
│       └── websocket/
├── domain/
│   ├── entities/
│   └── usecases/
├── presentation/
│   ├── controllers/
│   ├── screens/
│   └── widgets/
│       ├── common/
│       └── ppe_indicators/
└── routes/
```

### Reusable Components

- **PPE Status Widget**: Reusable component for helmet/vest/shoes status
- **Detection Card**: Standardized card for person detection display
- **Alert List Item**: Consistent alert display across screens
- **Loading Skeletons**: Unified loading placeholders

### API Integration

- **Dio**: HTTP client for REST API calls
- **WebSocket Channel**: Realtime detection stream
- **Retry Logic**: Exponential backoff for failed requests
- **Timeout Handling**: 30 second default timeout

## Development Workflow

### Screen Implementation Process

For each UI screen provided:

1. **Analysis Phase**
   - Identify screen purpose and user role
   - Map user flow and navigation
   - List all data required from backend

2. **Contract Definition**
   - Create API contract document
   - Define request/response JSON schemas
   - Document all error scenarios

3. **Model Creation**
   - Create Dart models with JSON serialization
   - Add fromJson/toJson methods
   - Include validation logic

4. **Service Layer**
   - Implement API service methods
   - Create repository for data access
   - Add error handling and retry logic

5. **Controller Layer**
   - Create GetX controller
   - Define reactive state variables
   - Implement business logic methods

6. **UI Implementation**
   - Build screen using reusable widgets
   - Apply consistent styling
   - Handle loading/error/empty states

7. **Integration Testing**
   - Test with mock API data
   - Verify error handling
   - Validate realtime updates (if applicable)

### Code Quality Standards

- **Linting**: Follow `flutter_lints` with strict mode
- **Formatting**: Use `flutter format` with 80 character line length
- **Naming**: Use descriptive names following Dart conventions
- **Comments**: Document public APIs and complex logic

### Testing Strategy

- **Unit Tests**: Business logic in controllers and services
- **Widget Tests**: UI component behavior
- **Integration Tests**: Full user flows
- **Mock Services**: All tests must use mocked API/WebSocket

## Governance

### Amendment Procedure

1. Propose change with rationale
2. Update version following semantic versioning
3. Review all dependent templates
4. Update sync impact report
5. Document all changes

### Versioning Policy

- **MAJOR**: Principle removal or breaking governance changes
- **MINOR**: New principle added or significant expansion
- **PATCH**: Clarifications, wording improvements

### Compliance Review

- All feature plans MUST pass Constitution Check
- Violations MUST be justified in Complexity Tracking
- Preferred simpler solutions over complexity

### Living Document

This constitution guides the entire project lifecycle. When in doubt, refer to these principles before making architectural decisions.

**Version**: 1.0.0 | **Ratified**: 2026-02-04 | **Last Amended**: 2026-02-04
