# API Contract: Agent Verification Submission

**Endpoint**: `POST /api/agent/verification`
**Purpose**: Submit completed verification application for review
**Authentication**: Required (agent user)

## Request

```typescript
POST /api/agent/verification
Content-Type: multipart/form-data
Authorization: Bearer {token}

FormData:
- phoneVerified: "false"
- prcLicense: "string" (license number)
- licenseType: "real_estate_broker"
- licenseExpiry: "" (handled in future)
- experience: "" (handled in future)
- specializations: "[]" (JSON array)
- provinces: "[]" (JSON array of province names)
- cities: "[]" (JSON array of municipality names)
- licenseDocument: File (optional)
- idDocument: File (optional)
- addressDocument: File (optional)
```

## Response

### Success
```typescript
Status: 200 OK
Content-Type: application/json

{
  "success": true,
  "applicationId": "string",
  "status": "submitted",
  "submittedAt": "2025-10-12T10:30:00Z",
  "message": "Application submitted successfully"
}
```

### Error Responses
```typescript
Status: 400 Bad Request
{
  "success": false,
  "error": "Missing required documents" | "Invalid form data"
}

Status: 401 Unauthorized
{
  "success": false,
  "error": "Authentication required"
}

Status: 409 Conflict
{
  "success": false,
  "error": "Application already submitted"
}
```

## Contract Tests

### Successful Submission
```typescript
// Given: Authenticated agent with complete verification data
// When: POST with all required fields and documents
// Then: Returns 200 with application ID

// Given: Missing required documents
// When: POST incomplete data
// Then: Returns 400 with validation errors
```

### Duplicate Submission Prevention
```typescript
// Given: Agent with already submitted application
// When: POST new submission
// Then: Returns 409 conflict
```</content>
<parameter name="filePath">/home/boggss/espasyoMLS/specs/005-i-want-to/contracts/agent-verification-submit-api.md