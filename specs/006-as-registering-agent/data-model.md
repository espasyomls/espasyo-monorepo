# Data Model: Agent Registration and Verification Flow

**Feature**: Agent Registration and Verification Flow  
**Branch**: 006-as-registering-agent  
**Date**: 2025-10-14

## Overview

This document defines the data entities, relationships, validation rules, and state transitions for the agent registration and verification feature. The model supports the complete lifecycle from agent registration through verification with unlimited revision cycles.

## Core Entities

### User

Extends the existing user entity from NextAuth.js. Users become agents after Google OAuth registration through the "Become an Agent" flow.

**Source**: Already exists in NextAuth.js schema

**Attributes**:
- `id` (string, UUID): Unique identifier
- `email` (string): Email from Google OAuth (unique)
- `name` (string): Full name from Google
- `image` (string, optional): Profile photo URL from Google
- `role` (enum): `'user' | 'agent' | 'admin' | 'verification_admin'`
- `emailVerified` (datetime, optional): Email verification timestamp
- `createdAt` (datetime): Account creation timestamp
- `updatedAt` (datetime): Last update timestamp

**Relationships**:
- One User → One AgentProfile (if role includes 'agent')
- One User → Many VerificationApplications (as applicant)
- One User → Many VerificationApplications (as reviewer, if admin role)

**Validation Rules**:
- Email must be valid format
- Email must be unique
- Role must be one of defined enum values
- Users registering as agents automatically get role 'agent'

**State Transitions**:
```
user (regular) → agent (via "Become an Agent" registration)
agent → admin (manual elevation by super admin)
```

---

### AgentProfile

Stores professional information about real estate agents. Created after OAuth registration, populated during profile completion step.

**Attributes**:
- `id` (string, UUID): Unique identifier
- `userId` (string, UUID, foreign key): References User.id
- `bio` (text): Professional biography
- `specializations` (array<string>): Agent specializations
  - Valid values: `'residential' | 'commercial' | 'luxury' | 'land' | 'industrial' | 'rental'`
- `coverageAreas` (array<string>): Geographic coverage areas
  - Format: Philippine provinces/cities (e.g., "Metro Manila", "Cavite", "Laguna")
- `prcLicenseNumber` (string): PRC license number
- `phoneNumber` (string): Contact phone number
- `experience` (string): Years of experience or description
- `profilePhotoUrl` (string, optional): Agent photo (separate from User.image)
- `isProfileComplete` (boolean): Whether profile meets completion requirements
- `verificationStatus` (enum): Current verification state
  - Values: `'pending' | 'under_review' | 'verified' | 'rejected' | 'returned_for_revisions'`
- `verifiedAt` (datetime, optional): When agent was verified
- `createdAt` (datetime): Profile creation timestamp
- `updatedAt` (datetime): Last update timestamp

**Relationships**:
- One AgentProfile → One User
- One AgentProfile → Many VerificationApplications
- One AgentProfile → Many Properties (once verified)
- One AgentProfile → Many Listings (once verified)

**Validation Rules**:
- `userId` must reference existing User
- `bio` required, min 50 characters, max 2000 characters
- `specializations` required, min 1 item, max 5 items
- `coverageAreas` required, min 1 item, max 10 items
- `prcLicenseNumber` required, format: `^[A-Z0-9\-]+$`, min 5 chars
- `phoneNumber` required, format: Philippine number `^(\+63|0)?[0-9]{10}$`
- `experience` required, min 10 characters
- `isProfileComplete` is true only when all required fields are filled

**Completion Logic**:
```typescript
function isProfileComplete(profile: AgentProfile): boolean {
  return !!(
    profile.bio && profile.bio.length >= 50 &&
    profile.specializations && profile.specializations.length > 0 &&
    profile.coverageAreas && profile.coverageAreas.length > 0 &&
    profile.prcLicenseNumber &&
    profile.phoneNumber &&
    profile.experience && profile.experience.length >= 10
  )
}
```

**State Transitions**:
```
pending (initial) 
  ↓ [agent submits verification]
under_review
  ↓ [admin reviews]
  ├─→ verified (approved)
  ├─→ rejected (can resubmit)
  └─→ returned_for_revisions (unlimited cycles)
       ↓ [agent resubmits]
       under_review (back to review)
```

---

### VerificationApplication

Represents an agent's verification submission with documents and admin review history. Supports unlimited revision cycles.

**Attributes**:
- `id` (string, UUID): Unique identifier
- `agentProfileId` (string, UUID, foreign key): References AgentProfile.id
- `status` (enum): Application status
  - Values: `'draft' | 'submitted' | 'under_review' | 'approved' | 'rejected' | 'returned_for_revisions'`
- `isDraft` (boolean): Whether application is still being edited
- `submittedAt` (datetime, optional): When submitted for review
- `reviewedAt` (datetime, optional): When admin reviewed
- `reviewedBy` (string, UUID, optional, foreign key): References User.id (admin)
- `reviewNotes` (text, optional): Admin's review comments
- `adminFeedback` (JSON, optional): Structured feedback for returned applications
  ```typescript
  {
    general: string,
    fieldComments: { [field: string]: string },
    actionItems: string[],
    returnCount: number,
    reviewer: { id: string, name: string, timestamp: Date }
  }
  ```
- `resubmissionCount` (integer): Number of times resubmitted after rejection (default: 0)
- `returnCount` (integer): Number of times returned for revisions (default: 0)
- `approvedAt` (datetime, optional): When approved
- `rejectedAt` (datetime, optional): When rejected
- `createdAt` (datetime): Application creation timestamp
- `updatedAt` (datetime): Last update timestamp

**Relationships**:
- One VerificationApplication → One AgentProfile
- One VerificationApplication → Many VerificationDocuments
- One VerificationApplication → One User (as applicant)
- One VerificationApplication → One User (as reviewer, optional)

**Validation Rules**:
- `agentProfileId` must reference existing AgentProfile
- Status must be valid enum value
- `isDraft` can only be true when status is 'draft'
- `submittedAt` required when status is not 'draft'
- `reviewedBy` and `reviewNotes` required when status is 'approved', 'rejected', or 'returned_for_revisions'
- `adminFeedback` required when status is 'returned_for_revisions'
- Cannot submit without required documents attached

**State Transitions**:
```
draft (initial)
  ↓ [agent clicks submit]
submitted → under_review
  ↓ [admin reviews]
  ├─→ approved (terminal - agent becomes verified)
  ├─→ rejected (agent can resubmit, creates new application or reuses this one)
  └─→ returned_for_revisions
       ↓ [agent edits and resubmits]
       under_review (unlimited cycles)
```

**Transition Rules**:
```typescript
const validTransitions: Record<VerificationStatus, VerificationStatus[]> = {
  'draft': ['submitted'],
  'submitted': ['under_review'],
  'under_review': ['approved', 'rejected', 'returned_for_revisions'],
  'returned_for_revisions': ['under_review'], // Agent resubmits after revisions
  'rejected': [], // Terminal - agent must start new application or reuse with resubmit
  'approved': [] // Terminal
}

function canTransition(from: VerificationStatus, to: VerificationStatus): boolean {
  return validTransitions[from]?.includes(to) ?? false
}
```

---

### VerificationDocument

Represents uploaded documents for verification. Permanently retained for audit compliance.

**Attributes**:
- `id` (string, UUID): Unique identifier
- `verificationApplicationId` (string, UUID, foreign key): References VerificationApplication.id
- `documentType` (enum): Type of document
  - Required: `'prc_license' | 'government_id'`
  - Optional: `'professional_certification' | 'business_registration'`
- `fileName` (string): Original filename
- `fileSize` (integer): File size in bytes
- `mimeType` (string): File MIME type
  - Allowed: `'application/pdf' | 'image/jpeg' | 'image/png'`
- `s3Key` (string): S3 object key for file storage
- `s3Bucket` (string): S3 bucket name
- `uploadedAt` (datetime): Upload timestamp
- `uploadedBy` (string, UUID, foreign key): References User.id
- `isVerified` (boolean): Whether document passed verification
- `verificationNotes` (text, optional): Admin notes about document
- `replacedBy` (string, UUID, optional, foreign key): References another VerificationDocument.id if replaced
- `isActive` (boolean): Whether this is the current version (false if replaced)
- `createdAt` (datetime): Record creation timestamp

**Relationships**:
- One VerificationDocument → One VerificationApplication
- One VerificationDocument → One User (uploader)
- One VerificationDocument → One VerificationDocument (replacedBy, optional)

**Validation Rules**:
- `verificationApplicationId` must reference existing VerificationApplication
- `documentType` must be valid enum value
- `fileSize` must be ≤ 5MB (5,242,880 bytes)
- `mimeType` must be one of allowed types
- `s3Key` and `s3Bucket` required after successful upload
- Cannot have multiple active documents of same type for same application
- PRC license and government ID are required before submission

**Document Requirements Per Application**:
```typescript
const requiredDocuments = ['prc_license', 'government_id']
const optionalDocuments = ['professional_certification', 'business_registration']

function hasRequiredDocuments(applicationId: string): boolean {
  const documents = getActiveDocuments(applicationId)
  return requiredDocuments.every(type => 
    documents.some(doc => doc.documentType === type && doc.isActive)
  )
}
```

**Immutability for Audit**:
- Documents are never deleted from storage
- When replaced, old document is marked `isActive = false` and `replacedBy` points to new document
- All versions retained for audit trail
- S3 bucket configured with versioning enabled

---

### VerificationAuditLog

Tracks all state changes and actions for audit compliance.

**Attributes**:
- `id` (string, UUID): Unique identifier
- `verificationApplicationId` (string, UUID, foreign key): References VerificationApplication.id
- `action` (enum): Action performed
  - Values: `'created' | 'submitted' | 'approved' | 'rejected' | 'returned' | 'resubmitted' | 'document_uploaded' | 'document_replaced' | 'draft_saved'`
- `fromStatus` (string, optional): Previous status
- `toStatus` (string, optional): New status
- `actorId` (string, UUID, foreign key): References User.id (who performed action)
- `actorRole` (enum): Role of actor
  - Values: `'agent' | 'admin' | 'verification_admin' | 'system'`
- `metadata` (JSON): Additional context
  ```typescript
  {
    reason?: string,
    feedback?: AdminFeedback,
    documentType?: string,
    changes?: Record<string, any>
  }
  ```
- `ipAddress` (string, optional): Actor's IP address
- `userAgent` (string, optional): Actor's user agent
- `timestamp` (datetime): When action occurred

**Relationships**:
- One VerificationAuditLog → One VerificationApplication
- One VerificationAuditLog → One User (actor)

**Validation Rules**:
- `verificationApplicationId` must reference existing VerificationApplication
- `action` must be valid enum value
- `actorId` required unless `actorRole` is 'system'
- `timestamp` cannot be in the future

**Usage**:
```typescript
function logVerificationAction(
  applicationId: string,
  action: AuditAction,
  actor: User,
  metadata?: Record<string, any>
) {
  createAuditLog({
    verificationApplicationId: applicationId,
    action,
    actorId: actor.id,
    actorRole: actor.role,
    metadata,
    timestamp: new Date(),
    ipAddress: getClientIp(),
    userAgent: getClientUserAgent()
  })
}
```

---

### SessionActivity

Tracks user activity for 30-minute session timeout enforcement.

**Attributes**:
- `id` (string, UUID): Unique identifier
- `userId` (string, UUID, foreign key): References User.id
- `sessionToken` (string): NextAuth session token
- `lastActivityAt` (datetime): Last recorded activity
- `expiresAt` (datetime): When session expires (lastActivityAt + 30 minutes)
- `createdAt` (datetime): Session start timestamp

**Relationships**:
- One SessionActivity → One User

**Validation Rules**:
- `userId` must reference existing User
- `sessionToken` must be unique
- `expiresAt` must be after `lastActivityAt`
- Automatically updated on each authenticated request

**Timeout Logic**:
```typescript
function isSessionExpired(activity: SessionActivity): boolean {
  const now = new Date()
  const thirtyMinutesAgo = new Date(now.getTime() - 30 * 60 * 1000)
  return activity.lastActivityAt < thirtyMinutesAgo
}

function updateActivity(sessionToken: string): void {
  const now = new Date()
  updateSessionActivity({
    sessionToken,
    lastActivityAt: now,
    expiresAt: new Date(now.getTime() + 30 * 60 * 1000)
  })
}
```

---

## Relationships Diagram

```
User
  ├─→ AgentProfile (1:1)
  │     ├─→ VerificationApplication (1:N)
  │     │     ├─→ VerificationDocument (1:N)
  │     │     └─→ VerificationAuditLog (1:N)
  │     ├─→ Property (1:N, only if verified)
  │     └─→ Listing (1:N, only if verified)
  └─→ SessionActivity (1:1)

Admin User
  └─→ VerificationApplication (as reviewer, 1:N)
```

## Indexes for Performance

### AgentProfile
- `userId` (unique): Fast user → profile lookup
- `verificationStatus`: Filter by status for admin dashboard
- `verifiedAt`: Sort verified agents by date
- `(isProfileComplete, verificationStatus)`: Composite for filtering incomplete profiles

### VerificationApplication
- `agentProfileId`: Fast profile → applications lookup
- `status`: Filter applications by status for admin
- `submittedAt`: Sort by submission date
- `reviewedBy`: Admin's review history
- `(status, submittedAt)`: Composite for admin queue sorting

### VerificationDocument
- `verificationApplicationId`: Fast application → documents lookup
- `(verificationApplicationId, documentType, isActive)`: Find active documents by type
- `s3Key` (unique): Fast document retrieval by S3 key

### VerificationAuditLog
- `verificationApplicationId`: Full audit trail for application
- `timestamp`: Chronological sorting
- `(verificationApplicationId, timestamp)`: Optimized audit queries

### SessionActivity
- `userId`: Fast user → session lookup
- `sessionToken` (unique): Session validation
- `expiresAt`: Cleanup expired sessions

## Data Validation Schemas (Zod)

### AgentProfile Schema
```typescript
import { z } from 'zod'

export const agentProfileSchema = z.object({
  bio: z.string().min(50, 'Bio must be at least 50 characters').max(2000),
  specializations: z.array(z.enum([
    'residential', 'commercial', 'luxury', 'land', 'industrial', 'rental'
  ])).min(1).max(5),
  coverageAreas: z.array(z.string()).min(1).max(10),
  prcLicenseNumber: z.string().regex(/^[A-Z0-9\-]+$/).min(5),
  phoneNumber: z.string().regex(/^(\+63|0)?[0-9]{10}$/),
  experience: z.string().min(10),
  profilePhotoUrl: z.string().url().optional()
})
```

### VerificationApplication Schema
```typescript
export const verificationApplicationSchema = z.object({
  // Required documents validation
  documents: z.array(z.object({
    type: z.enum(['prc_license', 'government_id', 'professional_certification', 'business_registration']),
    fileId: z.string().uuid()
  })).refine(
    (docs) => docs.some(d => d.type === 'prc_license') && docs.some(d => d.type === 'government_id'),
    'PRC license and government ID are required'
  )
})
```

### Document Upload Schema
```typescript
export const documentUploadSchema = z.object({
  fileName: z.string().min(1).max(255),
  fileSize: z.number().max(5 * 1024 * 1024, 'File size must be under 5MB'),
  mimeType: z.enum(['application/pdf', 'image/jpeg', 'image/png']),
  documentType: z.enum(['prc_license', 'government_id', 'professional_certification', 'business_registration'])
})
```

### Admin Review Schema
```typescript
export const adminReviewSchema = z.object({
  action: z.enum(['approve', 'reject', 'return']),
  reviewNotes: z.string().min(10, 'Review notes must be at least 10 characters'),
  feedback: z.object({
    general: z.string(),
    fieldComments: z.record(z.string(), z.string()).optional(),
    actionItems: z.array(z.string()).optional()
  }).optional().refine(
    (feedback, ctx) => {
      if (ctx.parent.action === 'return' && !feedback) {
        return false
      }
      return true
    },
    'Feedback is required when returning application'
  )
})
```

## Data Retention Policy

- **Agent Profiles**: Retained indefinitely, soft-delete only
- **Verification Applications**: Retained permanently for audit
- **Documents**: Never deleted, immutable with versioning
- **Audit Logs**: Retained for 7 years minimum (compliance)
- **Session Activity**: Cleaned up after 30 days of inactivity
- **Draft Data**: Retained permanently per clarification (audit requirement)

## Migration Considerations

### From Existing System
- User table already exists from NextAuth.js schema
- Need to add AgentProfile table
- Need to add verification-related tables
- Migration script to populate default values for existing users

### Future Enhancements
- Consider partitioning VerificationAuditLog by date for performance
- Add full-text search index on AgentProfile.bio for directory search
- Consider separate table for document metadata vs. S3 references

## Implementation Readiness

✅ All entities defined with attributes and relationships  
✅ Validation rules specified for each entity  
✅ State transitions documented with FSM  
✅ Indexes identified for performance  
✅ Zod schemas provided for runtime validation  
✅ Data retention policy defined  

**Ready for API Contract Definition**
