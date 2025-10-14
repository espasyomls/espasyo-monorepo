# API Contract: Agent Verification Draft

**Endpoint**: `POST /api/agent/verification/draft`
**Purpose**: Save or load verification draft data
**Authentication**: Required (agent user)

## Request

### Save Draft
```typescript
POST /api/agent/verification/draft
Content-Type: application/json
Authorization: Bearer {token}

{
  "stepData": {
    "agentInfo": {
      "firstName": "string",
      "lastName": "string",
      "email": "string",
      "phone": "string",
      "company": "string?",
      "licenseNumber": "string?"
    },
    "documents": {
      "identityDocument": "File?",
      "licenseDocument": "File?",
      "certificationDocument": "File?",
      "businessRegistrationDocument": "File?"
    },
    "serviceArea": {
      "provinces": "string[]",
      "municipalities": "string[]",
      "coverageRadius": "number?"
    }
  },
  "currentStep": "agent-info" | "documents" | "service-area"
}
```

### Load Draft
```typescript
GET /api/agent/verification/draft
Authorization: Bearer {token}
```

## Response

### Save Draft Success
```typescript
Status: 200 OK
Content-Type: application/json

{
  "success": true,
  "draftId": "string",
  "savedAt": "2025-10-12T10:30:00Z",
  "expiresAt": "2025-11-11T10:30:00Z"
}
```

### Load Draft Success
```typescript
Status: 200 OK
Content-Type: application/json

{
  "success": true,
  "draft": {
    "id": "string",
    "stepData": { /* same structure as save */ },
    "currentStep": "string",
    "savedAt": "2025-10-12T10:30:00Z",
    "expiresAt": "2025-11-11T10:30:00Z"
  }
}
```

### Error Responses
```typescript
Status: 401 Unauthorized
{
  "success": false,
  "error": "Authentication required"
}

Status: 400 Bad Request
{
  "success": false,
  "error": "Invalid draft data"
}

Status: 404 Not Found
{
  "success": false,
  "error": "Draft not found or expired"
}
```

## Contract Tests

### Save Draft Test
```typescript
// Given: Authenticated agent user
// When: POST valid draft data
// Then: Returns 200 with draft ID and timestamps

// Given: Invalid draft data
// When: POST malformed data
// Then: Returns 400 with validation errors
```

### Load Draft Test
```typescript
// Given: Authenticated agent with existing draft
// When: GET draft
// Then: Returns 200 with draft data

// Given: No existing draft
// When: GET draft
// Then: Returns 404
```</content>
<parameter name="filePath">/home/boggss/espasyoMLS/specs/005-i-want-to/contracts/agent-verification-draft-api.json