# API Contract: Admin Verification List

**Endpoint**: `GET /api/admin/agent-verifications`
**Purpose**: Retrieve list of agent verification applications for admin review
**Authentication**: Required (admin user with review permissions)

## Request

```typescript
GET /api/admin/agent-verifications?status={status}&page={page}&limit={limit}
Authorization: Bearer {admin_token}

Query Parameters:
- status: "submitted" | "under_review" | "approved" | "rejected" | "returned" (optional)
- page: number (default: 1)
- limit: number (default: 20, max: 100)
```

## Response

### Success
```typescript
Status: 200 OK
Content-Type: application/json

{
  "success": true,
  "applications": [
    {
      "id": "string",
      "agentId": "string",
      "agentEmail": "agent@gmail.com",
      "agentName": "John Doe",
      "status": "submitted",
      "submittedAt": "2025-10-12T10:30:00Z",
      "documents": [
        {
          "id": "string",
          "type": "license",
          "filename": "license.pdf",
          "verified": false
        }
      ]
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "totalPages": 8
  }
}
```

### Error Responses
```typescript
Status: 401 Unauthorized
{
  "success": false,
  "error": "Admin authentication required"
}

Status: 403 Forbidden
{
  "success": false,
  "error": "Insufficient permissions"
}
```

## Contract Tests

### List Applications
```typescript
// Given: Authenticated admin
// When: GET applications
// Then: Returns 200 with paginated list

// Given: Admin with insufficient permissions
// When: GET applications
// Then: Returns 403 forbidden
```

### Filtering
```typescript
// Given: Applications with different statuses
// When: GET with status=submitted
// Then: Returns only submitted applications
```</content>
<parameter name="filePath">/home/boggss/espasyoMLS/specs/005-i-want-to/contracts/admin-verification-list-api.md