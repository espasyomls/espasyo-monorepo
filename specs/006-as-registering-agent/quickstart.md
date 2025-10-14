# Quick Start: Agent Registration and Verification Flow

**Feature**: Agent Registration and Verification Flow  
**Branch**: 006-as-registering-agent  
**Date**: 2025-10-14

## Overview

This quick start guide provides everything needed to begin implementing the agent registration and verification feature.

## Prerequisites

- Next.js 15+ project (espasyo-frontend)
- NextAuth.js 5 configured with Google OAuth
- PostgreSQL database
- LocalStack for S3 (local development)
- Node.js 18+

## Installation

```bash
cd espasyo-frontend

# Install new dependencies
npm install react-hook-form @hookform/resolvers zod date-fns lodash.debounce

# Install dev dependencies
npm install -D @testing-library/user-event msw
```

## Environment Variables

Add to `espasyo-frontend/.env.local`:

```env
# Existing (from previous features)
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
NEXTAUTH_SECRET=your_nextauth_secret
NEXTAUTH_URL=http://localhost:3000

# New for this feature
AWS_S3_BUCKET_NAME=espasyo-agent-documents-local
AWS_S3_REGION=us-east-1
AWS_S3_ENDPOINT=http://localhost:4566  # LocalStack
AWS_ACCESS_KEY_ID=test  # LocalStack
AWS_SECRET_ACCESS_KEY=test  # LocalStack

# Session configuration
SESSION_TIMEOUT_MINUTES=30
MAX_FILE_UPLOAD_SIZE_MB=5
```

## Database Setup

Run migrations to create new tables:

```sql
-- Run these in PostgreSQL

-- AgentProfile table
CREATE TABLE agent_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id),
  bio TEXT,
  specializations TEXT[],
  coverage_areas TEXT[],
  prc_license_number VARCHAR(255),
  phone_number VARCHAR(20),
  experience TEXT,
  profile_photo_url TEXT,
  is_profile_complete BOOLEAN DEFAULT FALSE,
  verification_status VARCHAR(50) DEFAULT 'pending',
  verified_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_agent_profiles_user_id ON agent_profiles(user_id);
CREATE INDEX idx_agent_profiles_verification_status ON agent_profiles(verification_status);

-- VerificationApplication table
CREATE TABLE verification_applications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agent_profile_id UUID NOT NULL REFERENCES agent_profiles(id),
  status VARCHAR(50) DEFAULT 'draft',
  is_draft BOOLEAN DEFAULT TRUE,
  submitted_at TIMESTAMP,
  reviewed_at TIMESTAMP,
  reviewed_by UUID REFERENCES users(id),
  review_notes TEXT,
  admin_feedback JSONB,
  resubmission_count INTEGER DEFAULT 0,
  return_count INTEGER DEFAULT 0,
  approved_at TIMESTAMP,
  rejected_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_verification_applications_agent_profile ON verification_applications(agent_profile_id);
CREATE INDEX idx_verification_applications_status ON verification_applications(status);

-- VerificationDocument table
CREATE TABLE verification_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  verification_application_id UUID NOT NULL REFERENCES verification_applications(id),
  document_type VARCHAR(50) NOT NULL,
  file_name VARCHAR(255) NOT NULL,
  file_size INTEGER NOT NULL,
  mime_type VARCHAR(100) NOT NULL,
  s3_key VARCHAR(500) NOT NULL,
  s3_bucket VARCHAR(255) NOT NULL,
  uploaded_at TIMESTAMP DEFAULT NOW(),
  uploaded_by UUID NOT NULL REFERENCES users(id),
  is_verified BOOLEAN DEFAULT FALSE,
  verification_notes TEXT,
  replaced_by UUID REFERENCES verification_documents(id),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_verification_documents_application ON verification_documents(verification_application_id);

-- VerificationAuditLog table
CREATE TABLE verification_audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  verification_application_id UUID NOT NULL REFERENCES verification_applications(id),
  action VARCHAR(50) NOT NULL,
  from_status VARCHAR(50),
  to_status VARCHAR(50),
  actor_id UUID REFERENCES users(id),
  actor_role VARCHAR(50) NOT NULL,
  metadata JSONB,
  ip_address VARCHAR(45),
  user_agent TEXT,
  timestamp TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_verification_audit_logs_application ON verification_audit_logs(verification_application_id);
CREATE INDEX idx_verification_audit_logs_timestamp ON verification_audit_logs(timestamp);

-- SessionActivity table
CREATE TABLE session_activities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  session_token VARCHAR(255) NOT NULL UNIQUE,
  last_activity_at TIMESTAMP DEFAULT NOW(),
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_session_activities_user ON session_activities(user_id);
CREATE INDEX idx_session_activities_token ON session_activities(session_token);
```

## LocalStack Setup

Configure S3 bucket for document uploads:

```bash
# In espasyo-infrastructure directory
cat > localstack/init-scripts/create-agent-documents-bucket.sh << 'EOF'
#!/bin/bash
awslocal s3 mb s3://espasyo-agent-documents-local
awslocal s3api put-bucket-versioning \
  --bucket espasyo-agent-documents-local \
  --versioning-configuration Status=Enabled
echo "Agent documents bucket created with versioning enabled"
EOF

chmod +x localstack/init-scripts/create-agent-documents-bucket.sh

# Start LocalStack
docker-compose -f docker-compose.local.yml up -d
```

## Key Files to Create

### 1. Landing Page "Become an Agent" Button

File: `espasyo-frontend/app/page.tsx`

Add to header:
```typescript
<Button onClick={() => setShowAgentModal(true)}>
  Become an Agent
</Button>
```

### 2. Agent Registration Modal

File: `espasyo-frontend/src/components/auth/agent-registration-modal.tsx`

Shows "Continue with Google" button that triggers OAuth.

### 3. Agent Dashboard with Tabs

File: `espasyo-frontend/app/(dashboard)/dashboard/agent/page.tsx`

Three main sections:
- Profile completion banner (if incomplete)
- Personal Profile tab
- Verification tab

### 4. Profile Form

File: `espasyo-frontend/src/components/auth/agent-profile-form.tsx`

Form fields:
- Bio (textarea, min 50 chars)
- Specializations (multi-select)
- Coverage Areas (multi-select)
- PRC License Number
- Phone Number
- Experience

### 5. Verification Flow

File: `espasyo-frontend/src/components/auth/verification-flow.tsx`

Multi-step wizard:
1. Agent Info (from profile)
2. Document Upload (PRC license, ID)
3. Review & Submit

### 6. API Routes

Create these API routes:
- `app/api/agent/profile/route.ts` - CRUD for profile
- `app/api/agent/verification/route.ts` - Submit verification
- `app/api/agent/verification/draft/route.ts` - Save/load draft
- `app/api/admin/verification/route.ts` - List applications
- `app/api/admin/verification/[id]/review/route.ts` - Review actions

## Development Workflow

### Phase 1: Setup & Authentication
1. Verify Google OAuth works
2. Test "Become an Agent" button
3. Confirm agent role assignment

### Phase 2: Profile Completion
1. Create profile form
2. Implement validation
3. Test profile save/load

### Phase 3: Verification Flow
1. Create multi-step wizard
2. Implement document upload
3. Test draft persistence

### Phase 4: Admin Review
1. Create admin dashboard
2. Implement review actions
3. Test approval/rejection/return flows

### Phase 5: Public Directory
1. Create agents listing page
2. Create individual agent pages
3. Test SEO optimization

## Testing Strategy

Run tests in this order:

```bash
# Unit tests
npm run test -- tests/unit/

# Contract tests
npm run test -- tests/contracts/

# Integration tests
npm run test -- tests/integration/
```

## Common Pitfalls

1. **Session timeout during file upload**: Ensure auto-save runs before upload
2. **Large file uploads**: Use signed URLs, not direct API upload
3. **Draft data sync**: Always save to API, use LocalStorage as cache only
4. **Role checks**: Verify role at API level, not just UI level
5. **Document immutability**: Never delete documents, mark as inactive instead

## Next Steps

1. Review [data-model.md](./data-model.md) for entity relationships
2. Check [research.md](./research.md) for technical decisions
3. Read [contracts/](./contracts/) for API specifications
4. Run `/speckit.tasks` to generate implementation tasks

## Resources

- [Next.js App Router Docs](https://nextjs.org/docs/app)
- [React Hook Form](https://react-hook-form.com/)
- [shadcn/ui Components](https://ui.shadcn.com/)
- [NextAuth.js](https://next-auth.js.org/)
- [Zod Validation](https://zod.dev/)

## Support

For questions about this feature, refer to:
- Specification: [spec.md](./spec.md)
- Implementation Plan: [plan.md](./plan.md)
- Project Constitution: `../.specify/memory/constitution.md`
