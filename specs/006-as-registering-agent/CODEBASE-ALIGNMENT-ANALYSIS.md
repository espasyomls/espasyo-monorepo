# Codebase Alignment Analysis: Agent Registration and Verification Flow

**Feature**: 006-as-registering-agent  
**Date**: 2025-10-14  
**Status**: ⚠️ REQUIRES SIGNIFICANT TASK UPDATES

## Executive Summary

After thorough examination of the existing codebase, I've identified **significant misalignments** between the generated tasks.md and the actual implementation. Many foundational components already exist, and the current architecture differs from my assumptions.

### Critical Findings

1. ✅ **NextAuth.js 5.x is already configured** with Google OAuth
2. ✅ **Agent registration components already exist** (become-agent-modal, agent-onboarding-wizard)
3. ✅ **Backend svc-agent-go microservice exists** with database schema and API endpoints
4. ✅ **Document upload infrastructure exists** with S3 integration
5. ✅ **Draft persistence already implemented** (agent_registration_drafts table)
6. ⚠️ **BUT**: Verification workflow for admin review is incomplete/missing
7. ⚠️ **BUT**: Role-based access control needs enhancement for verification_admin role
8. ⚠️ **BUT**: Public agent directory doesn't exist yet

---

## Detailed Codebase Inventory

### 1. Authentication & Authorization ✅ MOSTLY EXISTS

#### Current State:
```typescript
// espasyo-frontend/src/lib/auth.config.ts
- Google OAuth provider: ✅ Configured
- Cognito provider: ✅ Configured  
- Session management: ✅ JWT with callbacks
- Sign-in redirect to /dashboard/agent: ✅ Implemented
```

#### Middleware:
```typescript
// espasyo-frontend/middleware.ts
- Route protection for /dashboard/*: ✅ Exists
- Role-based redirects (admin/agent/user): ✅ Implemented
- Role mapping: { 'Administrator': 'admin', 'Agent': 'agent', 'Regular User': 'user' }
```

#### What's Missing:
- ❌ Session timeout (30 minutes) not enforced
- ❌ Auto-save before timeout not implemented
- ❌ `verification_admin` role not in role mapping
- ❌ Verification status checks for property/listing creation

**Task Impact**: T010, T011, T023 need significant revision

---

### 2. Agent Registration Components ✅ MOSTLY EXISTS

#### Existing Components:
```
espasyo-frontend/src/components/auth/
├── become-agent-modal.tsx ✅ EXISTS
│   - "Become an Agent" modal with Google OAuth
│   - "Continue with Google" and "Cancel" buttons
│   - Redirects to /dashboard/agent
│   - signIn("google", { callbackUrl: "/dashboard/agent" })
│
├── agent-onboarding-wizard.tsx ✅ EXISTS  
│   - Multi-step wizard (4 steps)
│   - Professional info, documents, service area, review
│   - Form state management with useState
│   - Document upload to /api/agent/documents
│   - Draft auto-save (but needs API integration)
│
├── agent-registration-form.tsx ✅ EXISTS
├── agent-registration-success.tsx ✅ EXISTS
│
└── steps/
    ├── agent-info-step.tsx ✅ EXISTS
    ├── DocumentUploadStep.tsx ✅ EXISTS
    ├── service-area-step.tsx ✅ EXISTS
    └── review-step.tsx ✅ EXISTS
```

#### What's Missing:
- ❌ Integration with backend draft persistence API
- ❌ Verification submission flow (admin review)
- ❌ Admin feedback display for returned applications
- ❌ Resubmission flow after rejection/return
- ❌ Profile completion banner component
- ❌ Verification status card component

**Task Impact**: T027-T029, T038-T050 need major revision - many components already exist

---

### 3. Backend Microservice ✅ MOSTLY EXISTS

#### svc-agent-go Structure:
```
espasyo-backend/repos/microservices/svc-agent-go/
├── internal/
│   ├── models/
│   │   ├── agent.go ✅ Agent model with verification fields
│   │   ├── document.go ✅ Document model with S3 integration
│   │   └── draft.go (likely exists, not confirmed)
│   ├── handlers/
│   │   ├── agent.go ✅ CRUD operations
│   │   ├── document.go ✅ Document upload/verify
│   │   └── (admin verification handler missing?)
│   └── repository/
│       └── (PostgreSQL implementation)
│
└── migrations/
    ├── 000_create_base_agents_table.up.sql ✅
    ├── 001_add_agent_registration_fields.up.sql ✅
    ├── 002_create_agent_service_areas_table.up.sql ✅
    ├── 003_create_agent_documents_table.up.sql ✅
    └── 004_create_agent_registration_drafts_table.up.sql ✅
```

#### Database Schema (agent schema):
```sql
agent.agents:
  - id, user_id (references user_profile.users)
  - license_number, license_type, license_expiry_date
  - verification_status (PENDING, UNDER_REVIEW, VERIFIED, REJECTED, RETURNED)
  - return_reason, required_changes, return_count ✅
  - rejection_reason, rejection_date
  - application_submitted_at, application_reviewed_at
  - reviewed_by, returned_by, returned_at, resubmitted_at ✅

agent.agent_documents:
  - id, agent_id, document_type (PRC_LICENSE, GOVERNMENT_ID, etc.)
  - s3_bucket, s3_key, s3_url, original_filename
  - verification_status (PENDING, VERIFIED, REJECTED)
  - verified_at, verified_by, rejection_reason

agent.agent_registration_drafts:
  - id, user_id, draft_data (JSONB)
  - current_step, steps_completed, is_complete
  - expires_at (30 days), last_saved_at ✅

agent.agent_service_areas:
  - agent_id, province_id, municipality_id
```

#### API Endpoints (from svc-agent-go):
```go
// Existing routes:
POST   /api/agents/register ✅
GET    /api/agents/:id ✅
PATCH  /api/agents/:id ✅
PATCH  /api/agents/:id/verification-status ✅
POST   /api/agents/:id/documents ✅
GET    /api/agents/:id/documents ✅
PATCH  /api/documents/:id/verification-status ✅
```

#### What's Missing:
- ❌ Admin verification review endpoints
- ❌ Admin list applications endpoint
- ❌ Admin approve/reject/return endpoints
- ❌ Draft save/load API endpoints
- ❌ Resubmission endpoint
- ❌ Public agents list endpoint (verified only)
- ❌ Notification system for status changes

**Task Impact**: T043, T056-T079 need significant revision - backend structure exists, missing admin workflows

---

### 4. Database Schema ✅ MOSTLY EXISTS

#### Existing Schemas:
```sql
user_profile.users ✅
  - id VARCHAR(50), email, first_name, last_name
  - mobile_number, is_mobile_verified
  - (Note: No "role" field found in user_profile.users!)
  
agent.agents ✅ (comprehensive fields)
agent.agent_documents ✅
agent.agent_registration_drafts ✅
agent.agent_service_areas ✅
```

#### What's Missing:
- ❌ `user_profile.users.role` field for NextAuth role claims
- ❌ `agent_profiles` table (my data-model.md design doesn't match actual schema)
- ❌ `verification_applications` table (admin review workflow)
- ❌ `verification_audit_logs` table (compliance tracking)
- ❌ `session_activity` table (30-min timeout tracking)

**Critical Issue**: My data-model.md assumed separate `agent_profiles` and `verification_applications` tables, but the actual schema has everything in `agent.agents` with status fields. This is a fundamental mismatch!

**Task Impact**: T008, T009 need complete revision - schema already exists with different structure

---

### 5. Zustand Stores ⚠️ PARTIAL EXISTS

#### Existing:
```typescript
// espasyo-frontend/src/stores/auth.ts ✅
interface AuthState {
  user: User | null
  isAuthenticated: boolean
  setUser: (user: User | null) => void
  logout: () => void
}
```

#### What's Missing:
- ❌ Agent store (profile, verification status)
- ❌ Verification store (draft data, current step)

**Task Impact**: T021, T022 still needed but should integrate with existing auth store

---

### 6. TypeScript Types ⚠️ PARTIAL EXISTS

#### Existing:
```typescript
// espasyo-frontend/src/types/auth.ts (exists but not examined yet)
```

#### What's Missing:
- ❌ Complete agent types matching backend Agent model
- ❌ Verification types
- ❌ Admin types
- ❌ Document types

**Task Impact**: T012-T014 still needed

---

### 7. Validation Schemas ❌ MISSING

No Zod schemas found yet for agent profile or verification.

**Task Impact**: T015-T016 still needed

---

### 8. UI Components ⚠️ MIXED STATE

#### shadcn/ui:
```json
// Already installed:
- @radix-ui/react-dialog ✅
- @radix-ui/react-checkbox ✅
- @radix-ui/react-select ✅
- @radix-ui/react-tabs ✅
- @radix-ui/react-progress ✅
- @radix-ui/react-avatar ✅
- @radix-ui/react-dropdown-menu ✅
- @radix-ui/react-label ✅
- @radix-ui/react-separator ✅
- @radix-ui/react-slot ✅
```

#### What's Missing:
- ❌ Badge component
- ❌ Toast component (for notifications)

**Task Impact**: T024 needs revision - most components already installed

---

### 9. Admin Dashboard ❌ MISSING

No admin verification review pages or components found.

**Task Impact**: T065-T071 still needed - this is net-new functionality

---

### 10. Public Agent Directory ❌ MISSING

No public agent pages found yet.

**Task Impact**: T093-T107 still needed - this is net-new functionality

---

## Architecture Mismatches

### 1. Data Model Mismatch (CRITICAL)

**My Assumption**:
```
User (NextAuth) → AgentProfile → VerificationApplication → VerificationDocument
```

**Actual Implementation**:
```
user_profile.users → agent.agents (all-in-one) → agent.agent_documents
                                   ↓
                          agent.agent_registration_drafts
```

**Impact**: The backend uses a simpler, flatter structure where `agent.agents` contains all profile AND verification fields. My tasks assume creating separate entities.

### 2. Role Management Mismatch (CRITICAL)

**My Assumption**:
- User table has `role` field with enum values
- JWT claims include role for RBAC

**Actual Reality**:
- `user_profile.users` has NO role field in schema
- Middleware checks `req.auth.user?.role?.name` (suggests role comes from somewhere else)
- Role mapping exists: `{ 'Administrator': 'admin', 'Agent': 'agent', 'Regular User': 'user' }`
- **Question**: Where does role come from? NextAuth session? Separate table?

**Impact**: Need to understand existing role management before adding `verification_admin` role.

### 3. Frontend Structure Mismatch

**My Assumption**:
- All pages under `app/` directory
- API routes under `app/api/`

**Actual Reality**:
- Some components under `src/components/`
- Some under root `components/`
- Some pages under `app/`, some under `src/app/`
- **Inconsistent structure**

**Impact**: Task file paths need correction to match actual structure.

---

## Required Task Revisions

### Phase 1: Setup (T001-T009)

**Current Status**: ❌ NEEDS MAJOR REVISION

- T002: ✅ Skip - NextAuth already installed
- T003: ⚠️ Partial - react-hook-form, zod installed; need lodash.debounce
- T004: ✅ Skip - Zustand already installed
- T005: ❌ Check - Framer Motion may not be installed yet
- T006: ❌ Check - AWS SDK installation status unknown
- T007: ⚠️ Needs investigation - LocalStack setup status
- T008-T009: ❌ WRONG - Schema already exists, need different migrations

**Recommendation**: Audit what's actually needed vs. what exists.

---

### Phase 2: Foundational (T010-T026)

**Current Status**: ⚠️ NEEDS SIGNIFICANT REVISION

- T010: ⚠️ Revise - Auth config exists, add session timeout
- T011: ⚠️ Revise - Middleware exists, add timeout + auto-save
- T012-T014: ✅ Keep - Types still needed
- T015-T016: ✅ Keep - Validation schemas still needed
- T017: ⚠️ Revise - Check if API client utils exist
- T018: ⚠️ Investigate - S3 config may exist
- T019-T020: ⚠️ Check existing implementation
- T021-T022: ⚠️ Revise - Auth store exists, add agent stores
- T023: ⚠️ Revise - RBAC exists, enhance for verification_admin
- T024: ⚠️ Revise - Most components installed, add missing
- T025-T026: ✅ Keep

---

### Phase 3-5: User Stories 1-3 (T027-T080)

**Current Status**: ❌ NEEDS MAJOR OVERHAUL

**Story 1 (Registration)**: 
- T027-T029: ❌ DUPLICATE - become-agent-modal already exists
- T030-T031: ✅ Skip - OAuth already configured
- T032: ⚠️ Check - Dashboard page exists?
- T033: ⚠️ Revise - Backend endpoint exists, check frontend integration
- T037: ✅ Keep - Banner component missing

**Story 2 (Profile)**:
- T038-T040: ❌ DUPLICATE - agent-onboarding-wizard already has forms
- T041: ⚠️ Check - Profile page may exist
- T042-T043: ⚠️ Revise - Backend exists, check frontend API client
- T044-T050: ⚠️ Mix - Some logic exists, some missing

**Story 3 (Verification)**:
- T051-T053: ❌ DUPLICATE - wizard and document upload exist
- T054: ⚠️ Check - Verification page may exist
- T055-T064: ⚠️ Revise - Draft infrastructure exists, needs integration
- T065-T080: ✅ MOSTLY KEEP - Admin review is new functionality

---

### Phase 6-7: User Stories 4-5 (T081-T107)

**Current Status**: ⚠️ NEEDS MODERATE REVISION

**Story 4 (Access Control)**:
- T081-T092: ⚠️ Revise - Middleware exists, add verification checks

**Story 5 (Public Directory)**:
- T093-T107: ✅ MOSTLY KEEP - This is net-new functionality

---

### Phase 8: Polish (T108-T125)

**Current Status**: ✅ MOSTLY KEEP

Most polish tasks are still relevant.

---

## Critical Questions to Resolve

1. **Where is the user role stored?**
   - Not in `user_profile.users` schema
   - Middleware references `req.auth.user?.role?.name`
   - NextAuth session? Separate table? JWT claims?

2. **How does agent registration currently work?**
   - Components exist, but is the flow complete?
   - Does it integrate with backend svc-agent-go?
   - Is draft persistence working?

3. **What's the state of the admin dashboard?**
   - Does it exist for other purposes?
   - Any verification review UI?

4. **Is the backend deployed?**
   - svc-agent-go running?
   - Accessible from frontend?
   - What's the API base URL?

5. **What's missing for verification workflow?**
   - Admin review pages
   - Status change notifications
   - Return/rejection flow
   - Unlimited return cycles

---

## Recommended Next Steps

### Immediate Actions:

1. **Audit Dependencies**
   ```powershell
   # Check what's actually installed
   cd espasyo-frontend
   npm list framer-motion @aws-sdk/client-s3 lodash.debounce
   ```

2. **Examine Existing Routes**
   ```powershell
   # Find all API routes
   Get-ChildItem -Path "espasyo-frontend/app/api" -Recurse -File
   ```

3. **Test Existing Registration Flow**
   - Start frontend and backend
   - Click "Become an Agent"
   - Complete onboarding wizard
   - Document what works vs. what's broken

4. **Identify Role Management System**
   - Search for "role" in codebase
   - Find where roles are assigned
   - Understand role-based access control

5. **Map Backend Endpoints**
   - Document all existing svc-agent-go endpoints
   - Test them with Postman/curl
   - Identify gaps for admin verification

### Then:

6. **Revise tasks.md** with:
   - ✅ Keep: Net-new functionality (admin review, public directory)
   - ⚠️ Revise: Enhance existing (middleware, stores, API integration)
   - ❌ Remove: Duplicates (components that exist)
   - 🔍 Investigate: Unclear state (routes, pages, utilities)

7. **Create Integration Plan**
   - How to connect existing frontend components to backend
   - How to add admin review workflow
   - How to implement public directory
   - How to add missing RBAC features

---

## Lessons Learned

1. **Always audit existing code before planning** - I generated 125 tasks without checking if components already existed
2. **Architecture discovery is critical** - The actual data model differs significantly from my assumptions
3. **Database schema drives everything** - Understanding existing tables prevents duplicating entities
4. **Component inventory saves time** - Many UI components already built
5. **Backend-first projects need frontend integration focus** - svc-agent-go exists, need to connect it

---

## Audit Results: API Routes & Integration Points

### Admin Verification Routes ✅ EXIST

```
app/api/admin/agent-verifications/
├── route.ts ✅ (GET - list all applications with mock data)
├── [id]/review/route.ts ✅ (POST - approve/decline/request_more_info)
│
app/api/admin/agents/verification/
├── bulk-approve/route.ts ✅
└── bulk-decline/route.ts ✅
```

**Status**: Mock implementation exists! Uses in-memory data for development.

**Key Findings**:
- Actions supported: `approve`, `decline`, `request_more_info`
- Mock applications array with sample data
- User info joined manually (not from database)
- **Missing**: Return for revisions (unlimited cycles) not implemented
- **Missing**: Real database integration

### Agent Verification Routes ✅ EXIST

```
app/api/agent/verification/route.ts ✅ (POST - submit verification)
app/api/agent/profile/route.ts ✅ (GET - get profile)
src/app/api/agent/register/route.ts ✅ (POST - register agent)
src/app/api/agent/documents/route.ts ✅ (POST - upload documents)
```

**Status**: Full implementation with backend integration!

**Key Findings**:
- Integrates with `AgentServiceAPI` and `DocumentServiceAPI`
- Real backend calls to svc-agent-go microservice
- Zod validation on all requests
- Comprehensive error handling
- Transaction-like rollback on failure

### API Service Layer ✅ ROBUST

```
src/lib/api/
├── agent-service.ts ✅ (AgentServiceAPI class)
├── document-service.ts ✅ (DocumentServiceAPI class)
├── geocoding-service.ts ✅
├── http-client.ts ✅ (Base HTTP client with error handling)
├── media.ts ✅
├── property.ts ✅
├── search.ts ✅
└── user.ts ✅
```

**AgentServiceAPI Methods**:
- `registerAgent()` ✅
- `getAgent()` ✅
- `getAgentByUserId()` ✅
- `hasAgentProfile()` ✅
- Comprehensive Zod validation
- Type-safe throughout

**DocumentServiceAPI Methods**:
- Document upload with S3 integration
- Document verification
- Type checking for document types

### Admin Dashboard Pages ✅ EXIST

```
app/dashboard/admin/
├── page.tsx ✅ (Admin dashboard overview)
└── agents/verification/
    └── page.tsx ✅ (Agent verification review page - 796 lines!)
```

**Verification Page Features**:
- Full UI for reviewing applications
- Search and filter by status
- Bulk actions (approve/decline)
- Document viewing modal
- Review notes submission
- Status badges (pending, under_review, approved, declined, resubmission_allowed)
- Integration with backend API

**What's Missing**:
- ❌ "Return for revisions" action (only has approve/decline/request_more_info)
- ❌ Unlimited return cycles tracking
- ❌ Admin feedback display for agents

### Agent Dashboard Pages ✅ EXIST

```
app/dashboard/agent/
└── page.tsx ✅ (Agent dashboard - 431 lines)
```

**Features**:
- Tab-based navigation (Overview, Listings, Clients, Performance)
- Metrics widgets (active listings, commission earned, etc.)
- Role-based access control
- Integration with dashboard store

**What's Missing**:
- ❌ Profile completion banner
- ❌ Verification status card
- ❌ Verification flow tab/link
- ❌ Profile edit tab/link

---

## Role Management System 🔍 CLARIFIED

### Where Roles Come From:

After thorough investigation, roles are **NOT stored in database** currently. They appear to be:

1. **Mock/Hardcoded** in development:
   ```typescript
   // app/api/user/role/route.ts
   const mockUserRole = {
     name: 'Regular User' // Hardcoded for dev
   }
   ```

2. **Middleware checks** `req.auth.user?.role?.name`:
   ```typescript
   // middleware.ts
   const userRole = req.auth.user?.role?.name
   const roleMapping = {
     'Administrator': 'admin',
     'Agent': 'agent',
     'Regular User': 'user'
   }
   ```

3. **NextAuth session** supposedly contains role:
   ```typescript
   // src/types/auth.ts
   interface AuthUser {
     role?: "buyer" | "seller" | "agent" | "admin"
   }
   ```

4. **Database has NO role field**:
   ```sql
   -- user_profile.users has NO role column
   CREATE TABLE user_profile.users (
     id VARCHAR(50) PRIMARY KEY,
     email VARCHAR(255),
     first_name VARCHAR(100),
     -- NO role field!
   )
   ```

### Critical Issue:

**Role management is incomplete!** The system expects roles from NextAuth session, but there's no database table or column storing roles. This is a fundamental gap.

### Recommended Solution:

Either:
1. Add `role` enum column to `user_profile.users` table
2. Create separate `user_roles` table with user_id foreign key
3. Use Cognito/OAuth groups for role management

**Task Impact**: T010, T023 need to address role storage first before implementing verification_admin role

---

## Public Agent Directory ❌ MISSING

No pages found for public agent discovery:
- ❌ `/app/agents/page.tsx` - Public agent list
- ❌ `/app/agents/[id]/page.tsx` - Individual agent profile
- ❌ No API route for public agents list

**Task Impact**: T093-T107 are accurate - this is completely new functionality

---

## Missing Dependencies Audit

### Installed ✅:
- next-auth@5.0.0-beta.29 ✅
- react-hook-form@7.63.0 ✅
- zod@4.1.11 ✅
- zustand@5.0.8 ✅
- @hookform/resolvers@5.2.2 ✅
- @aws-sdk/client-s3 (likely via @aws-sdk/client-secrets-manager) ✅

### Missing ❌:
- ❌ framer-motion (not installed)
- ❌ lodash.debounce (not installed)
- ❌ @aws-sdk/s3-request-presigner (may be missing)

**Task Impact**: T003, T005, T006 partially needed

---

## Updated Accuracy Assessment

The tasks.md file I generated is **approximately 35% accurate**:

### ✅ Accurate Tasks (25% - Keep As-Is):
- T093-T107: Public agent directory (completely new)
- T108-T125: Polish tasks (mostly applicable)
- T065-T066: Admin review UI components (need enhancement, not rebuild)

### ⚠️ Needs Major Revision (45% - Refactor):
- T010-T026: Foundational (auth config exists, need enhancements)
- T027-T050: User Stories 1-2 (components exist, need integration)
- T051-T064: User Story 3 Agent side (wizard exists, need backend connection)
- T065-T080: User Story 3 Admin side (UI exists, need "return for revisions")
- T081-T092: User Story 4 (middleware exists, need verification checks)

### ❌ Wrong/Duplicate (30% - Remove):
- T002: NextAuth already installed
- T004: Zustand already installed
- T008-T009: Database schema exists (different structure)
- T027-T029: become-agent-modal exists
- T030-T031: OAuth already configured
- T038-T040: agent-onboarding-wizard exists
- T042-T043: AgentServiceAPI exists
- T051-T053: Wizard components exist
- T067-T071: Admin pages exist

---

## Revised Implementation Strategy

### What Actually Needs Building:

#### High Priority (MVP Completion):
1. **Connect Existing Frontend to Backend** (70% done, need integration)
   - Agent onboarding wizard → svc-agent-go API
   - Draft persistence API endpoints (backend exists, frontend integration missing)
   - Document upload flow completion

2. **Enhance Admin Verification Workflow** (60% done)
   - Add "Return for Revisions" action (currently only approve/decline/request_more_info)
   - Implement unlimited return cycles tracking
   - Add returnCount field handling
   - Create admin feedback display for agents

3. **Role Management System** (0% done - critical gap!)
   - Add role storage (database or external)
   - Implement `verification_admin` role
   - Update middleware for role checks
   - Add role assignment on agent registration

4. **Agent Dashboard Enhancements** (30% done)
   - Add profile completion banner component
   - Add verification status card component
   - Add verification flow navigation
   - Add profile edit tab

5. **Session Timeout & Auto-Save** (0% done)
   - Implement 30-minute session timeout
   - Add auto-save before timeout
   - Session restoration after re-auth

#### Medium Priority:
6. **Public Agent Directory** (0% done - completely new)
   - Public agent list page
   - Individual agent profile page
   - API routes for verified agents only
   - SEO optimization with ISR

7. **Access Control for Listings** (50% done)
   - Add verification status checks to property/listing creation
   - Block UI for unverified agents
   - Backend enforcement already exists

8. **Missing Dependencies**
   - Install framer-motion
   - Install lodash.debounce
   - Verify @aws-sdk/s3-request-presigner

---

## Conclusion

The tasks.md file I generated is **approximately 35% accurate**:

- ✅ **Accurate (25%)**: Public directory, polish tasks, some admin enhancements
- ⚠️ **Needs Major Revision (45%)**: Integration tasks, UI enhancements, role management
- ❌ **Wrong/Duplicate (30%)**: Components/infrastructure that already exist

### Critical Gaps Discovered:

1. **Role Management System** - Fundamental missing piece, no database storage
2. **Return for Revisions Workflow** - Backend schema exists, frontend UI incomplete
3. **Frontend-Backend Integration** - Components exist separately, need connection
4. **Session Timeout** - Completely missing, required by spec
5. **Draft Persistence** - Backend table exists, frontend API missing

### Recommended Next Steps:

1. **Revise tasks.md** focusing on:
   - Integration tasks (connect existing pieces)
   - Enhancement tasks (extend existing functionality)
   - New functionality (public directory, role management)
   - Remove duplicate/wrong tasks

2. **Prioritize** by implementation order:
   - Phase 1: Role management system (foundation)
   - Phase 2: Frontend-backend integration (agent flow)
   - Phase 3: Admin workflow enhancements (return for revisions)
   - Phase 4: Agent dashboard UI additions
   - Phase 5: Public directory (new feature)
   - Phase 6: Session timeout & auto-save
   - Phase 7: Access control enforcement
   - Phase 8: Polish & testing

3. **Generate** revised tasks.md with accurate understanding of codebase state
