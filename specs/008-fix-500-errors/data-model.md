# Data Model: Fix 500 Errors in Agent Profile API

**Feature**: Fix 500 Errors in Agent Profile API
**Date**: 2025-10-19
**Purpose**: Define data entities, relationships, and validation rules for agent profile API stability

## Entity Definitions

### User Entity

**Purpose**: Represents authenticated users in the system

**Fields**:
- `id` (string, UUID): Unique identifier, primary key
- `email` (string): User's email address, unique, required
- `firstName` (string): User's first name, required
- `lastName` (string): User's last name, required
- `role` (string): User role (AGENT, ADMIN, USER), required
- `isEmailVerified` (boolean): Email verification status, default false
- `isMobileVerified` (boolean): Mobile verification status, default false
- `addressBarangay` (string): Address barangay, optional
- `addressCityMunicipality` (string): Address city/municipality, optional
- `addressProvince` (string): Address province, optional
- `addressCountry` (string): Address country, default "Philippines"
- `createdAt` (timestamp): Record creation timestamp
- `updatedAt` (timestamp): Record last update timestamp

**Validation Rules**:
- `id`: Must be valid UUID format
- `email`: Must be valid email format, unique across system
- `firstName`, `lastName`: Non-empty strings, max 100 characters
- `role`: Must be one of: AGENT, ADMIN, USER

**Relationships**:
- One-to-one with Agent entity (when role is AGENT)

### Agent Entity

**Purpose**: Represents agent-specific profile data

**Fields**:
- `id` (string, UUID): Unique identifier, primary key
- `userId` (string, UUID): Foreign key to User.id, required
- `licenseNumber` (string): Agent license number, optional
- `specialization` (string): Agent specialization, optional
- `yearsOfExperience` (integer): Years of experience, optional
- `bio` (text): Agent biography, optional
- `contactNumber` (string): Contact phone number, optional
- `createdAt` (timestamp): Record creation timestamp
- `updatedAt` (timestamp): Record last update timestamp

**Validation Rules**:
- `id`: Must be valid UUID format
- `userId`: Must reference existing User with role AGENT
- `licenseNumber`: Max 50 characters if provided
- `specialization`: Max 200 characters if provided
- `yearsOfExperience`: Must be positive integer if provided
- `bio`: Max 2000 characters if provided
- `contactNumber`: Must be valid phone format if provided

**Relationships**:
- Belongs to User entity (userId foreign key)

### API Response Entity

**Purpose**: Standardized response format for all API endpoints

**Success Response Structure**:
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "string",
      "email": "string",
      "firstName": "string",
      "lastName": "string",
      "role": "string",
      "isEmailVerified": boolean,
      "isMobileVerified": boolean,
      "addressBarangay": "string",
      "addressCityMunicipality": "string",
      "addressProvince": "string",
      "addressCountry": "string",
      "createdAt": "timestamp",
      "updatedAt": "timestamp"
    },
    "agent": {
      "id": "string",
      "userId": "string",
      "licenseNumber": "string",
      "specialization": "string",
      "yearsOfExperience": integer,
      "bio": "string",
      "contactNumber": "string",
      "createdAt": "timestamp",
      "updatedAt": "timestamp"
    }
  }
}
```

**Error Response Structure**:
```json
{
  "success": false,
  "error": {
    "code": "string",
    "message": "string"
  }
}
```

## Data Relationships

### Entity Relationships Diagram

```
User (1) ──── (0..1) Agent
  │
  └── role = "AGENT" (required for Agent relationship)
```

### Foreign Key Constraints

- Agent.userId → User.id (CASCADE on delete)
- User.role must be "AGENT" for Agent relationship to exist

## State Transitions

### User State Transitions

- **Created**: Initial state with basic information
- **Email Verified**: After email verification process
- **Mobile Verified**: After mobile verification process
- **Role Assigned**: When user role is set (AGENT, ADMIN, USER)

### Agent State Transitions

- **Created**: Initial agent profile creation
- **Profile Updated**: When agent information is modified
- **Deactivated**: When agent account is deactivated (soft delete)

## Validation Rules Summary

### Database-Level Validation

- Primary key constraints on User.id and Agent.id
- Unique constraint on User.email
- Foreign key constraint on Agent.userId
- Check constraints on User.role values
- Check constraints on Agent.yearsOfExperience (> 0)

### Application-Level Validation

- Email format validation
- Phone number format validation
- String length limits
- Required field validation
- Business rule validation (agent role requirement)

## Data Volume and Performance Considerations

- **Expected Scale**: 10,000 active users, 2,000 concurrent agents
- **Read Patterns**: Frequent user/agent profile lookups by ID and email
- **Write Patterns**: Occasional profile updates, rare new user creation
- **Indexing Strategy**:
  - User.email (unique index)
  - User.id (primary key index)
  - Agent.userId (foreign key index)
  - User.role (filtered index for agent queries)

## Migration Considerations

- Existing user data must be validated for role consistency
- Agent profiles may need to be created for existing users with AGENT role
- Data cleanup for invalid or incomplete records
- Backward compatibility for existing API consumers