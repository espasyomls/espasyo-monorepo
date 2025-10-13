# Data Model: Progressive Agent Verification Flow

## Entity Definitions

### Agent
**Purpose**: Represents a real estate professional seeking verification
**Attributes**:
- `id`: string (unique identifier)
- `email`: string (Gmail address, unique)
- `firstName`: string (optional, from profile)
- `lastName`: string (optional, from profile)
- `phone`: string (optional)
- `company`: string (optional)
- `licenseNumber`: string (optional)
- `createdAt`: Date
- `updatedAt`: Date

**Relationships**:
- One-to-many with VerificationApplication
- One-to-one with Gmail OAuth account

**Validation Rules**:
- Email must be valid Gmail address
- Phone must match Philippine format if provided
- License number must be valid format if provided

### VerificationApplication
**Purpose**: Tracks an agent's verification submission and review process
**Attributes**:
- `id`: string (unique identifier)
- `agentId`: string (foreign key to Agent)
- `status`: enum ['not_started', 'in_progress', 'submitted', 'returned', 'approved', 'rejected']
- `submittedAt`: Date (optional)
- `reviewedAt`: Date (optional)
- `reviewerId`: string (optional, admin who reviewed)
- `reviewNotes`: string (optional)
- `additionalDocumentsRequested`: string[] (optional)
- `createdAt`: Date
- `updatedAt`: Date

**Relationships**:
- Many-to-one with Agent
- One-to-many with VerificationDocument
- One-to-one with VerificationDraft

**Validation Rules**:
- Status must follow valid transitions: not_started → in_progress → submitted → (returned → submitted) | approved | rejected
- Only admins can change status to approved/rejected/returned
- Additional documents requested only valid when status is 'returned'

### VerificationDocument
**Purpose**: Stores uploaded verification documents
**Attributes**:
- `id`: string (unique identifier)
- `applicationId`: string (foreign key to VerificationApplication)
- `type`: enum ['identity', 'license', 'certification', 'business_registration']
- `filename`: string
- `originalName`: string
- `mimeType`: string
- `size`: number (bytes)
- `url`: string (secure access URL)
- `uploadedAt`: Date
- `verified`: boolean (admin verification status)

**Relationships**:
- Many-to-one with VerificationApplication

**Validation Rules**:
- File size must be ≤ 10MB
- MIME type must match allowed types for document category
- URL must be secure (HTTPS)

### VerificationDraft
**Purpose**: Stores incomplete verification data for resume functionality
**Attributes**:
- `id`: string (unique identifier)
- `applicationId`: string (foreign key to VerificationApplication)
- `stepData`: JSON object containing form data by step
- `currentStep`: string (which step user was on)
- `createdAt`: Date
- `updatedAt`: Date
- `expiresAt`: Date (30 days from creation)

**Relationships**:
- One-to-one with VerificationApplication

**Validation Rules**:
- Automatically deleted when expiresAt is reached
- JSON schema validation for stepData structure

### Administrator
**Purpose**: Represents system administrators who review applications
**Attributes**:
- `id`: string (unique identifier)
- `email`: string (admin email, unique)
- `name`: string
- `role`: enum ['super_admin', 'verification_admin']
- `permissions`: string[] (array of permission strings)
- `createdAt`: Date
- `lastLoginAt`: Date (optional)

**Relationships**:
- One-to-many with VerificationApplication (as reviewer)

**Validation Rules**:
- Must have 'review_applications' permission for verification_admin role
- Super_admin has all permissions

## State Transitions

### Verification Application Status Flow
```
not_started → in_progress (agent starts verification)
in_progress → submitted (agent completes and submits)
submitted → returned (admin requests more documents)
submitted → approved (admin approves)
submitted → rejected (admin rejects)
returned → submitted (agent provides additional documents)
```

### Document Verification States
```
uploaded → under_review (initial state)
under_review → verified (admin approves)
under_review → rejected (admin rejects, requires re-upload)
```

## Data Integrity Rules

1. **Referential Integrity**: All foreign keys must reference existing records
2. **Status Consistency**: Status transitions must follow defined flows
3. **Data Retention**: Drafts auto-delete after 30 days, applications retained for 1 year
4. **Audit Trail**: All status changes and admin actions are logged
5. **File Security**: Documents stored securely with access controls

## Performance Considerations

- Index on agentId for fast application lookup
- Index on status for admin filtering
- File storage optimized for retrieval speed
- JSON validation cached for draft operations</content>
<parameter name="filePath">/home/boggss/espasyoMLS/specs/005-i-want-to/data-model.md