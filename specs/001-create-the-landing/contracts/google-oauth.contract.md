# Contract: Google OAuth Authentication

## Overview
This contract defines the interface for Google OAuth authentication used in the login and registration modals.

## API Endpoints

### POST /api/auth/google/signin
Initiates Google OAuth sign-in flow.

**Request:**
```json
{
  "redirectUrl": "string" // URL to redirect after authentication
}
```

**Response:**
```json
{
  "authUrl": "string" // Google OAuth URL to redirect user to
}
```

**Error Responses:**
- 400: Invalid redirect URL
- 500: OAuth configuration error

### GET /api/auth/google/callback
Handles OAuth callback from Google.

**Query Parameters:**
- code: Authorization code from Google
- state: State parameter for CSRF protection

**Response:**
```json
{
  "token": "string", // JWT token
  "user": {
    "id": "string",
    "email": "string",
    "name": "string"
  }
}
```

**Error Responses:**
- 400: Invalid authorization code
- 401: Authentication failed

### POST /api/auth/logout
Logs out the current user.

**Request:** None (uses session)

**Response:**
```json
{
  "success": true
}
```

## Data Models

### User
```typescript
interface User {
  id: string;
  email: string;
  name: string;
  picture?: string;
}
```

### AuthToken
```typescript
interface AuthToken {
  accessToken: string;
  refreshToken: string;
  expiresAt: number;
}
```

## Security Requirements
- HTTPS only
- CSRF protection on callbacks
- Secure token storage
- Rate limiting on auth endpoints

## Testing Contracts
- Mock OAuth responses for unit tests
- Integration tests with LocalStack Google OAuth simulation
- E2E tests for complete auth flow</content>
<parameter name="filePath">/home/boggss/espasyoMLS/specs/001-create-the-landing/contracts/google-oauth.contract.md