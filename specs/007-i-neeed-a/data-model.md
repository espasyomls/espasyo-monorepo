# Data Model: Logout Button in Dashboard

**Feature**: Logout Button in Dashboard  
**Date**: 2025-10-19  

## Entities

### User Session

**Purpose**: Represents the authenticated state of a user during their application session.

**Fields**:
- `sessionId`: string (UUID) - Unique identifier for the session
- `userId`: string (UUID) - Reference to the authenticated user
- `accessToken`: string - JWT access token for API authentication
- `refreshToken`: string (optional) - JWT refresh token for token renewal
- `expiresAt`: timestamp - When the session expires
- `createdAt`: timestamp - When the session was created
- `lastActivity`: timestamp - Last user activity in the session
- `ipAddress`: string - Client IP address for security tracking
- `userAgent`: string - Browser/client user agent string

**Validation Rules**:
- `sessionId` must be unique and valid UUID
- `userId` must reference existing user
- `accessToken` must be valid JWT signed with correct secret
- `expiresAt` must be in the future for active sessions
- `createdAt` must be before or equal to current time

**Relationships**:
- Belongs to User (one-to-many: User has many Sessions)
- May have associated Refresh Tokens

**State Transitions**:
- `CREATED` → `ACTIVE` (upon successful authentication)
- `ACTIVE` → `TERMINATED` (upon logout or expiration)
- `TERMINATED` → `EXPIRED` (cleanup after termination)

**Lifecycle**:
- Created during login/authentication
- Updated on user activity (optional, for session management)
- Terminated on logout (server-side invalidation)
- Cleaned up periodically (expired sessions removal)

## Data Flow

1. **Login**: Create new User Session with tokens
2. **Activity**: Update lastActivity timestamp
3. **Logout**: Mark session as TERMINATED, invalidate tokens
4. **Cleanup**: Remove expired TERMINATED sessions

## Storage Considerations

- **Primary Storage**: PostgreSQL (espasyo_dev database)
- **Indexing**: sessionId (unique), userId, expiresAt
- **Caching**: Redis for active session lookups (optional)
- **Security**: Tokens encrypted at rest, access logged

## Integration Points

- **Authentication Service**: Creates/manages sessions
- **Frontend**: Stores session tokens in localStorage/cookies
- **API Gateway (eDSL)**: Validates tokens against active sessions
- **Logout Endpoint**: Terminates session and invalidates tokens