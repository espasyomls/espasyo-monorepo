# API Contract: Admin Verification Review

**Endpoint**: `POST /api/admin/agent-verifications/{id}/review`
**Purpose**: Admin review actions on verification applications
**Authentication**: Required (admin user with review permissions)

## Request

### Approve Application
```typescript
POST /api/admin/agent-verifications/{applicationId}/review
Content-Type: application/json
Authorization: Bearer {admin_token}

{
  "action": "approve",
  "notes": "Application approved - all documents verified"
}
```

### Reject Application
```typescript
POST /api/admin/agent-verifications/{applicationId}/review
Content-Type: application/json
Authorization: Bearer {admin_token}

{
  "action": "reject",
  "notes": "Application rejected - invalid license"
}
```

### Request Additional Documents
```typescript
POST /api/admin/agent-verifications/{applicationId}/review
Content-Type: application/json
Authorization: Bearer {admin_token}

{
  "action": "request_documents",
  "notes": "Additional documents required",
  "additionalDocumentsRequested": [
    "Proof of business registration",
    "Additional property listings"
  ]
}
```

## Response

### Success
```typescript
Status: 200 OK
Content-Type: application/json

{
  "success": true,
  "applicationId": "string",
  "newStatus": "approved" | "rejected" | "returned",
  "reviewedAt": "2025-10-12T10:30:00Z",
  "reviewerId": "string",
  "message": "Application approved successfully"
}
```

### Error Responses
```typescript
Status: 400 Bad Request
{
  "success": false,
  "error": "Invalid action or missing required fields"
}

Status: 404 Not Found
{
  "success": false,
  "error": "Application not found"
}

Status: 409 Conflict
{
  "success": false,
  "error": "Application already reviewed"
}
```

## Contract Tests

### Approve Application
```typescript
// Given: Submitted application and authorized admin
// When: POST approve action
// Then: Returns 200, status changes to approved

// Given: Invalid application ID
// When: POST approve action
// Then: Returns 404
```

### Request Additional Documents
```typescript
// Given: Application needing more docs
// When: POST request_documents with document list
// Then: Returns 200, status changes to returned, documents listed
```</content>
<parameter name="filePath">/home/boggss/espasyoMLS/specs/005-i-want-to/contracts/admin-verification-review-api.md