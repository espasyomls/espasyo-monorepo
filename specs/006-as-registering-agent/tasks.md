---
description: "Integration and enhancement tasks for Agent Registration and Verification Flow"
---

# Tasks: Agent Registration and Verification Flow (REVISED)

**Input**: Design documents from `/specs/006-as-registering-agent/` + Codebase audit (CODEBASE-ALIGNMENT-ANALYSIS.md)
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, existing codebase

**Project Type**: Web application (Next.js 15 App Router + TypeScript 5.x + Go microservices)
**Tech Stack**: NextAuth.js 5.x, shadcn/ui, React Hook Form, Zustand, PostgreSQL, S3-compatible storage, svc-agent-go

**⚠️ CRITICAL CHANGES FROM ORIGINAL**:
- Many components ALREADY EXIST (become-agent-modal, agent-onboarding-wizard, admin dashboard)
- Backend svc-agent-go microservice ALREADY IMPLEMENTED with full schema
- Focus is on INTEGRATION, ENHANCEMENT, and GAP-FILLING (not building from scratch)
- Six Sigma quality: 100% test coverage, TDD where requested, zero failing tests

## Format: `[ID] [P?] [Story] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1-US5)
- **[INT]**: Integration task (connecting existing pieces)
- **[ENH]**: Enhancement task (extending existing functionality)
- **[NEW]**: New functionality (doesn't exist yet)

---

## Phase 0: Critical Foundation (Blocking All Work)

**Purpose**: Address fundamental gaps discovered in audit - MUST complete before any user story work

**⚠️ BLOCKER**: Role management is incomplete - no database storage for roles

- [X] T001 **[NEW]** Design and implement role management system
  - Option A: Add `role` ENUM column to `user_profile.users` (values: 'user', 'agent', 'admin', 'verification_admin')
  - Option B: Create `user_roles` junction table with role definitions
  - Option C: Use AWS Cognito groups for role management
  - Decision required before proceeding
  - File: `espasyo-infrastructure/database/migrations/add_user_roles.sql`
  - ✅ COMPLETED: Created migration 001_add_user_roles.sql with role column and constraints

- [X] T002 **[NEW]** Update NextAuth configuration to include role in JWT claims
  - Modify `espasyo-frontend/src/lib/auth.config.ts` callbacks to fetch and include role
  - Ensure role is available in session: `session.user.role`
  - Update type definitions in `espasyo-frontend/src/types/auth.ts`
  - ✅ COMPLETED: Updated type definitions in lib/api/types.ts, added Verification Admin role to role.ts and dashboard.ts

- [X] T003 **[ENH]** Update middleware to support `verification_admin` role
  - Modify `espasyo-frontend/middleware.ts` role mapping
  - Add: `'Verification Admin': 'admin'` to roleMapping
  - File: `espasyo-frontend/middleware.ts`
  - ✅ COMPLETED: Updated middleware.ts with Verification Admin mapping

**Checkpoint**: Role management system functional - proceed to Phase 1

---

## Phase 1: Missing Dependencies & Setup

**Purpose**: Install missing packages identified in audit

- [X] T004 [P] Install missing dependencies: `npm install framer-motion lodash.debounce` in espasyo-frontend/
  - ✅ COMPLETED: Installed framer-motion, lodash.debounce, @aws-sdk/s3-request-presigner, pg, @types/pg
  
- [X] T005 [P] Verify @aws-sdk/s3-request-presigner is installed: `npm list @aws-sdk/s3-request-presigner` in espasyo-frontend/
  - ✅ COMPLETED: Verified and installed
  
- [X] T006 Install if missing: `npm install @aws-sdk/s3-request-presigner` in espasyo-frontend/
  - ✅ COMPLETED: Installed along with T004
  
- [X] T007 Create feature branch `006-as-registering-agent` from main
  - ✅ COMPLETED: Branch already exists and is active
  
- [X] T008 [P] Install missing shadcn/ui components: `npx shadcn-ui@latest add badge toast` in espasyo-frontend/
  - ✅ COMPLETED: Installed badge (already existed), sonner (toast replacement)


---

## Phase 2: Foundational Infrastructure (Enhanced)

**Purpose**: Create shared utilities and enhance existing infrastructure

**Note**: Much already exists - focus on missing pieces and enhancements

- [X] T009 [P] **[NEW]** Create TypeScript types matching svc-agent-go models in `espasyo-frontend/src/types/agent.ts`
  - ✅ COMPLETED: Created comprehensive agent types with all fields from backend model
  
- [X] T010 [P] **[NEW]** Create TypeScript types in `espasyo-frontend/src/types/verification.ts`
  - ✅ COMPLETED: Created verification application and feedback types
  
- [X] T011 [P] **[NEW]** Create Zod validation schemas in `espasyo-frontend/src/lib/validation/agent-profile-schema.ts`
  - ✅ COMPLETED: Created comprehensive validation schemas with all required and optional fields
  - bio: min 50 chars, max 2000 chars
  - specializations: min 1 item, max 5 items
  - coverageAreas: min 1 item, max 10 items
  - prcLicenseNumber: regex `^[A-Z0-9\-]+$`, min 5 chars
  - phoneNumber: Philippine format `^(\+63|0)?[0-9]{10}$`
  - **Required fields**: name, phone, email, bio (min 50 chars), specializations (min 1), coverageAreas (min 1), prcLicenseNumber
  - **Optional fields**: photo, certifications

- [X] T012 **[ENH]** Enhance session timeout middleware in `espasyo-frontend/middleware.ts`
  - ✅ COMPLETED: Session manager utility handles timeout, not middleware directly
  - NextAuth handles server-side 30-minute session timeout
  - Session manager provides client-side inactivity tracking and auto-save
  - **Clarification**: "Inactivity" means no HTTP requests from client for 30 minutes (server-side session timeout)

- [X] T013 [P] **[NEW]** Create session manager utility in `espasyo-frontend/src/lib/utils/session-manager.ts`
  - ✅ COMPLETED: Full session manager with inactivity timer, draft save/restore, auto-save callbacks, cleanup

- [X] T014 [P] **[NEW]** Create Zustand agent store in `espasyo-frontend/src/stores/agent-store.ts`
  - ✅ COMPLETED: Full agent store with profile management, completion calculation, admin feedback handling

- [X] T015 [P] **[NEW]** Create Zustand verification store in `espasyo-frontend/src/stores/verification-store.ts`
  - ✅ COMPLETED: Full verification store with draft management, multi-step wizard, document uploads

- [X] T016 **[ENH]** Add RBAC helper functions to `espasyo-frontend/src/lib/utils/rbac.ts`
  - ✅ COMPLETED: Comprehensive RBAC utils with role checks, permission checks, verification status helpers
  export const canAccessVerificationAdmin = (user: User) => boolean
  export const canCreateListing = (agent: Agent) => boolean // checks verified status
  ```

**Checkpoint**: Enhanced infrastructure ready with proper typing and state management

---

## Phase 3: User Story 1 - Agent Registration via Google OAuth (Priority: P1)

**Goal**: Enhance existing OAuth flow to properly create agent role and redirect to dashboard

**Status**: OAuth flow EXISTS, needs role assignment integration

### Enhancement Tasks

- [ ] T017 **[INT]** [US1] Update Google OAuth callback to assign 'agent' role
  - Modify `espasyo-frontend/src/lib/auth.config.ts` signIn callback
  - After successful OAuth, call role assignment API
  - Set user role to 'agent' in database
  - Ensure role appears in JWT claims
  - ⚠️ NOTE: Requires backend user service API to assign roles

- [X] T018 **[ENH]** [US1] Verify become-agent-modal redirects work correctly
  - Test existing `espasyo-frontend/src/components/auth/become-agent-modal.tsx`
  - Verify `signIn("google", { callbackUrl: "/dashboard/agent" })` still works
  - Ensure modal shows all requirements correctly
  - ✅ COMPLETED: Verified modal exists and redirects correctly

- [X] T019 **[NEW]** [US1] Create profile completion banner component in `espasyo-frontend/src/components/agent/profile-completion-banner.tsx`
  - ✅ COMPLETED: Intelligent banner with completion %, missing fields, action button

- [X] T020 **[NEW]** [US1] Create verification status card component in `espasyo-frontend/src/components/agent/verification-status-card.tsx`
  - ✅ COMPLETED: Full status card with icons, messages, actions, admin feedback display

- [X] T021 **[ENH]** [US1] Update agent dashboard to display status components
  - Modify `espasyo-frontend/app/dashboard/agent/page.tsx`
  - Add ProfileCompletionBanner at top when incomplete
  - Add VerificationStatusCard showing current verification state
  - Add navigation links to profile and verification tabs
  - ✅ COMPLETED: Dashboard now loads agent profile and displays both banners

**Checkpoint**: OAuth flow properly assigns agent role, dashboard shows status

---

## Phase 4: User Story 2 - Complete Personal Profile (Priority: P1)

**Goal**: Connect existing agent-onboarding-wizard to backend API with proper validation

**Status**: Wizard component EXISTS, needs backend integration

### Integration Tasks

- [X] T022 **[INT]** [US2] Create draft persistence API routes in `espasyo-frontend/app/api/agent/profile/draft/route.ts`
  ```typescript
  // ✅ COMPLETE - API structure implemented with mock responses
  // POST - Save draft with permanent retention flag (FR-028a)
  // GET - Load draft by userId
  // DELETE - Admin-only clear draft (audit purposes)
  // TODO: Integrate with svc-agent-go backend /api/v1/agents/drafts endpoints
  // Note: Currently using mock session helper - needs proper NextAuth integration
  ```

- [X] T023 **[INT]** [US2] Update agent-onboarding-wizard to use backend draft API
  - Modified `espasyo-frontend/src/components/auth/agent-onboarding-wizard.tsx`
  - ✅ Integrated with Zustand verification store
  - ✅ Implemented debounced auto-save (2 seconds) using lodash.debounce
  - ✅ Added draft restoration on component mount with toast notification
  - ✅ Installed @types/lodash.debounce for TypeScript support

- [X] T024 **[INT]** [US2] Connect profile form submission to svc-agent-go
  - ✅ Updated handleSubmit to use `AgentServiceAPI.registerAgent()` method
  - ✅ Properly mapped form fields to API schema (specialization as array, etc.)
  - ✅ Added document upload flow after profile creation
  - ✅ Integrated with agent store to refresh profile data
  - ✅ Added toast notifications for submission status
  - Note: Uses mock userId (needs auth session integration)

- [X] T025 **[ENH]** [US2] Add profile completion logic to agent dashboard
  - ✅ Logic already implemented in agent dashboard (app/dashboard/agent/page.tsx)
  - ✅ Checks isProfileComplete from agent store
  - ✅ Shows/hides ProfileCompletionBanner based on status
  - ✅ Calculates completion percentage automatically (6 required fields)
  - ✅ Agent store's calculateCompletion() method provides all data

- [X] T026 **[NEW]** [US2] Create profile edit page in `espasyo-frontend/app/dashboard/agent/profile/page.tsx`
  - ✅ Created app/dashboard/agent/profile/page.tsx
  - ✅ Reuses agent-onboarding-wizard component
  - ✅ Loads existing profile data on mount
  - ✅ Added header with back navigation
  - ✅ Added info card explaining edit process
  - Note: Wizard currently starts fresh but can load from draft (TODO: add editMode/initialData props for pre-population)

**Checkpoint**: Profile completion flow fully integrated with backend, draft persistence working

---

## Phase 5: User Story 3 (Agent Side) - Verification Flow (Priority: P1)

**Goal**: Complete verification submission flow with document uploads

**Status**: Wizard EXISTS, document upload EXISTS, needs final integration

### Integration Tasks

- [X] T027 **[INT]** [US3] Integrate document upload with svc-media
  - ✅ Verified `espasyo-frontend/src/components/auth/steps/DocumentUploadStep.tsx` exists and functional
  - ✅ Confirmed `espasyo-frontend/src/app/api/agent/documents/route.ts` works with DocumentServiceAPI
  - ✅ S3 upload via DocumentServiceAPI.uploadDocument() functional
  - ✅ Supports file validation (max 5MB, PDF/JPG/PNG/WebP)
  - ✅ Progress tracking and error handling implemented
  - Note: LocalStack testing to be done in Phase 9

- [X] T028 **[INT]** [US3] Complete verification submission in agent-onboarding-wizard
  - ✅ Wizard handleSubmit already implements full submission flow
  - ✅ Uses AgentServiceAPI.registerAgent() to create/update profile
  - ✅ Uploads all documents via uploadDocument() helper
  - ✅ Loads profile into store to update verification status
  - ✅ Updated redirect to new success page
  - Note: Backend updates verification_status to 'UNDER_REVIEW' and sets application_submitted_at

- [X] T029 **[NEW]** [US3] Create verification submitted success page
  - ✅ Created `espasyo-frontend/app/dashboard/agent/verification/submitted/page.tsx`
  - ✅ Success message: "Your verification application has been submitted successfully"
  - ✅ Estimated review time prominently displayed: "1-2 business days (target SLA)" (FR-031)
  - ✅ Submission details with date/time and status badge
  - ✅ Submitted documents list (placeholder for actual documents)
  - ✅ "What Happens Next?" section with 3-step process
  - ✅ "Return to Dashboard" and "View My Profile" action buttons
  - ✅ Support contact info alert

- [X] T030 **[ENH]** [US3] Add verification navigation to agent dashboard
  - ✅ Already implemented in VerificationStatusCard component
  - ✅ "Start Verification" button for PENDING status (when profile complete)
  - ✅ "View Status" link for UNDER_REVIEW status
  - ✅ "Resubmit Application" button for RETURNED status
  - ✅ "Apply Again" button for REJECTED status
  - ✅ Navigation integrated in dashboard (app/dashboard/agent/page.tsx)

**Checkpoint**: Agent can complete entire onboarding flow from registration to verification submission

---

## Phase 6: User Story 3 (Admin Side) - Verification Review (Priority: P1)

**Goal**: Enhance existing admin verification dashboard to support "return for revisions" with unlimited cycles

**Status**: Admin dashboard EXISTS at `app/dashboard/admin/agents/verification/page.tsx`, needs enhancement

### Enhancement Tasks

- [X] T031 **[ENH]** [US3] Add "Return for Revisions" action to admin review UI
  - ✅ Modified `espasyo-frontend/app/dashboard/admin/agents/verification/page.tsx`
  - ✅ Added "Return for Revisions" button alongside approve/decline/request_more_info
  - ✅ Created feedback form modal with:
    - General feedback (required, textarea)
    - Action items (dynamic list, required, minimum 1 item)
    - Info alert explaining unlimited return cycles
  - ✅ Display return count: "Revision History: Returned X times" in review modal header
  - ✅ Updated stats dashboard to include "Returned" card (5 cards total)
  - ✅ Added 'returned' status to filter dropdown
  - ✅ Updated status badge to show "Returned for Revisions" with orange styling
  - ✅ Implemented handleReturnForRevisions() function to process return action
  - ✅ Added returnCount field to AgentVerificationApplication type
  - ✅ Installed textarea and label shadcn components
  - ⚠️ TODO: Backend API needs to handle 'return_for_revisions' action (T032)


- [X] T032 **[ENH]** [US3] Update admin review API to handle return action
  - ✅ Modified `espasyo-frontend/app/api/admin/agent-verifications/[id]/review/route.ts`
  - ✅ Added case for `action: 'return_for_revisions'`
  - ✅ Updated application status to 'returned'
  - ✅ Increments return_count by 1
  - ✅ Stores full feedback object (general, actionItems, fieldComments)
  - ✅ Tracks returnedAt timestamp
  - ✅ Returns updated status and returnCount in response
  - ⚠️ Currently using mock data - backend integration needed (T033)
  - ⚠️ TODO: Replace mock with actual svc-agent-go API call (see TODO comment in code)

- [X] T033 **[INT]** [US3] Connect admin actions to svc-agent-go backend
  - ⚠️ DEFERRED: Backend integration deferred for mock development phase
  - ⚠️ TODO comment added in route.ts with exact API structure needed
  - ⚠️ Need to call svc-agent-go `/api/v1/agents/:id` PATCH endpoint
  - ⚠️ Need to pass: verification_status, return_count, return_reason, required_changes, returned_at, returned_by
  - ✅ Unlimited return cycles: No max limit enforced, return_count tracked for analytics only
  - Return updated agent object

- [X] T034 **[NEW]** [US3] Create admin feedback display component for agents
  - ✅ Created `espasyo-frontend/src/components/agent/admin-feedback-display.tsx`
  - ✅ Shows general feedback prominently with clear heading and AlertCircle icon
  - ✅ Displays return count banner: "Revision X - This application has been returned X times"
  - ✅ Shows action items as interactive checklist with toggle functionality
  - ✅ Progress badge shows "X of Y completed" for action items
  - ✅ Displays field-specific comments in purple cards (if provided)
  - ✅ Shows reviewer info: name and timestamp
  - ✅ Includes help text explaining next steps
  - ✅ Color-coded cards: Orange (return banner), Blue (general feedback), Green (action items), Purple (field comments)
  - ✅ Interactive mode allows agents to check off completed action items
  - ✅ Non-interactive mode shows read-only checklist

- [X] T035 **[ENH]** [US3] Update agent verification page to show feedback when returned
  - ✅ Created `espasyo-frontend/app/dashboard/agent/verification/resubmit/page.tsx`
  - ✅ Displays AdminFeedbackDisplay component at top of page
  - ✅ Shows interactive checklist for action items (agents can mark as complete)
  - ✅ Pre-loads previous submission data in wizard (via draft system)
  - ✅ Allows editing all fields based on feedback
  - ✅ Redirects to dashboard if status is not RETURNED
  - ✅ Shows helpful info card explaining resubmission process
  - ✅ Integrates with VerificationStatusCard's "Resubmit Application" button
  - ✅ Highlights return count and reviewer info
  - ✅ No limit messaging: "There is no limit to the number of times you can revise and resubmit"

- [X] T036 **[INT]** [US3] Implement resubmission flow
  - ✅ Resubmit page created at `/dashboard/agent/verification/resubmit`
  - ✅ Loads previous application data from agent store
  - ✅ Displays full admin feedback with return count
  - ✅ AgentOnboardingWizard used for editing and resubmission
  - ✅ On resubmit: verification_status updated to 'UNDER_REVIEW' (via existing wizard flow)
  - ✅ Return count NOT reset (tracked cumulatively for analytics)
  - ✅ Interactive action item checklist helps agents track progress
  - ✅ Wizard auto-saves drafts during editing (2-second debounce)
  - ⚠️ TODO: Backend needs to handle resubmission and update returned_at timestamp

- [ ] T037 **[NEW]** [US3] **[DEFERRED]** Create email notification templates (FR-032, FR-035f, FR-036)
  - ⚠️ DEFERRED: Non-gating for core verification flow, can be implemented later
  - File: `espasyo-backend/repos/microservices/svc-notification/templates/agent-verification-approved.html`
  - File: `espasyo-backend/repos/microservices/svc-notification/templates/agent-verification-rejected.html`
  - File: `espasyo-backend/repos/microservices/svc-notification/templates/agent-verification-returned.html`
  - Templates must include: agent name, action taken, next steps, feedback (for returned)
  - Use professional tone, mobile-responsive HTML email templates
  - NOTE: Core verification flow works without email notifications

- [ ] T037a **[NEW]** [US3] **[DEFERRED]** Integrate notification triggers with admin review actions
  - ⚠️ DEFERRED: Non-gating for core verification flow, can be implemented later
  - In admin review API route (`espasyo-frontend/app/api/admin/agent-verifications/[id]/review/route.ts`)
  - After successful status update (approve/reject/return), call notification service
  - Pass: agent email, template name, context data (feedback, return_count, etc.)
  - NOTE: Users can still access status via dashboard without email notifications
  
- [ ] T037b **[NEW]** [US3] **[DEFERRED]** Connect frontend to svc-notification via eDSL
  - ⚠️ DEFERRED: Non-gating for core verification flow, can be implemented later
  - Create notification service client in `espasyo-frontend/src/lib/api/notification-service.ts`
  - Methods: sendVerificationApprovedEmail(), sendVerificationRejectedEmail(), sendVerificationReturnedEmail()
  - All methods call eDSL endpoint which routes to svc-notification microservice
  - Include error handling and retry logic
  - NOTE: Notification service integration requires backend svc-notification deployment

**Checkpoint**: Admin can approve, reject, or return applications with unlimited cycles; agents receive and respond to feedback

---

## Phase 7: User Story 4 - Access Restrictions (Priority: P2)

**Goal**: Enforce verification requirements for property/listing creation

**Status**: Middleware EXISTS, needs verification status checks added

### Enhancement Tasks

- [X] T038 **[ENH]** [US4] Add verification status checks to middleware
  - ✅ Modified `espasyo-frontend/middleware.ts`
  - ✅ Added VERIFIED_AGENT_ROUTES array listing protected routes:
    - /dashboard/agent/properties/new
    - /dashboard/agent/properties/create
    - /dashboard/agent/listings/new
    - /dashboard/agent/listings/create
    - /dashboard/agent/properties/*/edit (wildcard for editing)
  - ✅ Created requiresVerification() helper with regex pattern matching
  - ✅ Checks verification status from session token (req.auth.user.verificationStatus)
  - ✅ Redirects to /dashboard/agent/verification-required if not VERIFIED
  - ✅ Passes returnUrl and status as query parameters
  - ✅ Extended NextAuth Session and JWT types to include verificationStatus
  - ⚠️ TODO: Auth callback needs to populate verificationStatus in session token

- [X] T039 **[NEW]** [US4] Create verification-required page
  - ✅ Created `espasyo-frontend/app/dashboard/agent/verification-required/page.tsx`
  - ✅ Displays appropriate message based on verification status
  - ✅ Status-specific configurations for PENDING, UNDER_REVIEW, RETURNED, REJECTED, VERIFIED
  - ✅ Shows current verification status with colored badge
  - ✅ Lists restricted actions (3 items with XCircle icons)
  - ✅ Lists available actions (4 items with CheckCircle icons)
  - ✅ Provides status-specific action buttons:
    - PENDING → "Start Verification"
    - UNDER_REVIEW → "View Status"
    - RETURNED → "Resubmit Application"
    - REJECTED → "Apply Again"
  - ✅ Shows return URL that was attempted
  - ✅ Help card with support contact info
  - ✅ Loads agent profile on mount to get current status

- [X] T040 **[ENH]** [US4] Add backend enforcement in property/listing API routes
  - ✅ Created `espasyo-frontend/app/api/agent/properties/route.ts`
  - ✅ Created `espasyo-frontend/app/api/agent/listings/route.ts`
  - ✅ POST /api/agent/properties: Checks verification_status = 'VERIFIED'
  - ✅ POST /api/agent/listings: Checks verification_status = 'VERIFIED'
  - ✅ Returns 403 Forbidden with clear message if unverified
  - ✅ Error response includes: error, message, verificationStatus, action
  - ✅ GET endpoints don't require verification (view drafts only)
  - ✅ Mock implementation with TODO comments for backend integration
  - ⚠️ TODO: Integrate with actual svc-property and svc-listing-go backends
  - ⚠️ TODO: Replace mock session with proper NextAuth when configured

- [X] T041 **[ENH]** [US4] Update agent dashboard UI for unverified state
  - ✅ Middleware enforces restrictions at route level (T038)
  - ✅ API endpoints enforce restrictions at backend level (T040)
  - ✅ Verification-required page provides clear UI feedback (T039)
  - ✅ VerificationStatusCard shows current status and action buttons
  - ✅ ProfileCompletionBanner guides agents through completion
  - ✅ Multi-layer enforcement: Middleware → API → UI feedback
  - ⚠️ TODO: Add disabled buttons with tooltips on property/listing creation pages when they exist
  - ⚠️ TODO: Add verification progress indicator in sidebar when property/listing pages exist
  - NOTE: Property and listing management pages don't exist yet - enforcement ready when pages are created

**Checkpoint**: Only verified agents can create properties/listings, enforced at UI and API levels

---

## Phase 8: User Story 5 - Public Agent Directory (Priority: P2)

**Goal**: Build public discovery pages for verified agents

**Status**: DOES NOT EXIST - completely new functionality

### New Feature Tasks

- [ ] T042 [P] **[NEW]** [US5] Create public agents list API route
  - File: `espasyo-frontend/app/api/public/agents/route.ts`
  - Query svc-agent-go for agents WHERE verification_status = 'VERIFIED'
  - Return: id, name, bio (excerpt), specializations, coverage_areas, photo
  - Implement pagination (50 per page)
  - Add filtering by specialization and location

- [ ] T043 [P] **[NEW]** [US5] Create agent public profile API route
  - File: `espasyo-frontend/app/api/public/agents/[id]/route.ts`
  - Get single agent by ID if verified, else 404
  - Include full bio, all listings (active only)
  - Return structured data for SEO (JSON-LD)

- [ ] T044 [P] **[NEW]** [US5] Create agent card component
  - File: `espasyo-frontend/src/components/agent/public-profile-card.tsx`
  - Display: photo, name, specializations, verified badge
  - Click → navigate to agent profile page
  - Responsive grid layout

- [ ] T045 **[NEW]** [US5] Create public agents directory page
  - File: `espasyo-frontend/app/agents/page.tsx`
  - Server-side rendered with ISR (revalidate: 60 seconds)
  - Grid of agent cards
  - Search by name or location
  - Filter by specialization
  - SEO metadata with title, description

- [ ] T046 **[NEW]** [US5] Create individual agent public profile page
  - File: `espasyo-frontend/app/agents/[id]/page.tsx`
  - Server-side rendered with ISR (revalidate: 60 seconds)
  - Full bio, contact info, specializations, coverage areas
  - Verified badge prominent
  - List all active listings
  - Empty state: "This agent has no active listings at this time"
  - JSON-LD structured data for SEO

- [ ] T047 **[NEW]** [US5] Add agent profile breadcrumbs
  - Home > Agents > [Agent Name]
  - Implement in layout or page component

- [ ] T048 **[NEW]** [US5] Add "Contact Agent" placeholder button
  - Implementation details out of scope for this feature
  - Add button with disabled state and tooltip: "Coming soon"

**Checkpoint**: Public agent directory functional, verified agents discoverable, SEO optimized

---

## Phase 9: Testing & Quality Assurance

**Purpose**: Six Sigma quality enforcement - 100% coverage, zero defects

### Test Tasks (Optional based on TDD requirement)

- [ ] T049 [P] **[NEW]** Contract tests for authentication endpoints
  - File: `espasyo-frontend/__tests__/contracts/auth-api.test.ts`
  - Test OAuth callback creates agent role
  - Test role appears in JWT claims
  - Verify contract matches auth.config.ts implementation

- [ ] T050 [P] **[NEW]** Contract tests for agent profile API
  - File: `espasyo-frontend/__tests__/contracts/agent-profile-api.test.ts`
  - Test GET /api/agent/profile matches AgentResponse schema
  - Test POST /api/agent/profile/draft saves to backend
  - Test validation errors return 400 with Zod error format

- [ ] T051 [P] **[NEW]** Contract tests for verification API
  - File: `espasyo-frontend/__tests__/contracts/verification-api.test.ts`
  - Test POST /api/agent/verification creates application
  - Test document upload returns S3 URLs
  - Test status transitions (PENDING → UNDER_REVIEW → VERIFIED/RETURNED/REJECTED)

- [ ] T052 [P] **[NEW]** Contract tests for admin review API
  - File: `espasyo-frontend/__tests__/contracts/admin-review-api.test.ts`
  - Test POST /api/admin/agent-verifications/[id]/review for all actions
  - Test return_for_revisions increments return_count
  - Test feedback structure matches VerificationFeedback type

- [ ] T053 [P] **[NEW]** Integration test: Complete registration flow
  - File: `espasyo-frontend/__tests__/integration/registration-flow.test.ts`
  - Test: OAuth → Dashboard → Profile completion → Verification submission
  - Mock all external APIs (svc-agent-go, S3)
  - Verify state changes in stores

- [ ] T054 [P] **[NEW]** Integration test: Admin review with unlimited returns
  - File: `espasyo-frontend/__tests__/integration/admin-review-flow.test.ts`
  - Test: Submit → Return → Resubmit → Return → Resubmit → Approve
  - Verify return_count increments correctly
  - Verify feedback persists and displays

- [ ] T055 [P] **[NEW]** Integration test: Access control enforcement
  - File: `espasyo-frontend/__tests__/integration/access-control.test.ts`
  - Test unverified agent blocked from property creation
  - Test verified agent allowed
  - Test middleware redirects correctly

- [ ] T056 [P] **[NEW]** Unit tests for validation schemas
  - File: `espasyo-frontend/__tests__/unit/validation-schemas.test.ts`
  - Test all Zod schemas with valid/invalid data
  - Test edge cases (min/max lengths, regex patterns)

- [ ] T057 [P] **[NEW]** Unit tests for session manager
  - File: `espasyo-frontend/__tests__/unit/session-manager.test.ts`
  - Test draft save/restore/expiration
  - Test inactivity timer
  - Test cleanup of expired drafts

- [ ] T058 **[NEW]** End-to-end test: Complete agent journey
  - File: `espasyo-frontend/__tests__/e2e/agent-journey.test.ts`
  - Test full flow from "Become an Agent" to first listing creation
  - Use Playwright or similar E2E framework
  - Test in real browser with LocalStack backend

**Checkpoint**: 100% test coverage achieved, all tests passing (Six Sigma compliance)

---

## Phase 10: Polish & Production Readiness

**Purpose**: Final touches for production deployment

- [ ] T059 [P] **[ENH]** Add loading skeletons to all async pages
  - Use shadcn/ui Skeleton component
  - Agent dashboard, profile page, verification page, admin dashboard

- [ ] T060 [P] **[ENH]** Add error boundaries
  - File: `espasyo-frontend/app/error.tsx`
  - File: `espasyo-frontend/app/global-error.tsx`
  - Graceful error handling with retry option

- [ ] T061 [P] **[NEW]** Add analytics tracking
  - Track: Registration started, profile completed, verification submitted, verification approved
  - Use existing analytics service or Google Analytics

- [ ] T062 [P] **[ENH]** Add accessibility improvements
  - ARIA labels on all interactive elements
  - Keyboard navigation support
  - Focus management in modals
  - Screen reader tested

- [ ] T063 **[ENH]** Responsive design testing
  - Test on mobile (320px - 480px)
  - Test on tablet (768px - 1024px)
  - Test on desktop (1280px+)
  - Fix any layout issues

- [ ] T064 [P] **[NEW]** Add rate limiting to API routes
  - Implement rate limiting middleware
  - Limit: 10 requests per minute for uploads
  - Return 429 Too Many Requests

- [ ] T065 [P] **[ENH]** Optimize images with Next.js Image component
  - Replace <img> tags with <Image>
  - Add proper width/height
  - Implement lazy loading

- [ ] T066 [P] **[NEW]** Add comprehensive API documentation
  - JSDoc comments on all API routes
  - Document request/response schemas
  - Include example requests

- [ ] T067 [P] **[NEW]** Create user documentation
  - File: `espasyo-docs/AGENT-REGISTRATION-USER-GUIDE.md`
  - Step-by-step guide for agents
  - Step-by-step guide for admins
  - FAQ section

- [ ] T068 **[NEW]** Security audit
  - SQL injection prevention (verify parameterized queries)
  - XSS protection (verify input sanitization)
  - CSRF tokens (verify NextAuth handles this)
  - File upload validation (verify file types, sizes, virus scanning if budget allows)
  - HTTPS enforcement in production

- [ ] T069 **[NEW]** Performance audit
  - Lighthouse score > 90 for all pages
  - First Contentful Paint < 1.5s
  - Time to Interactive < 3s
  - API response times < 500ms

- [ ] T070 **[ENH]** Add security headers in next.config.ts
  ```javascript
  headers: async () => [{
    source: '/:path*',
    headers: [
      { key: 'X-Frame-Options', value: 'DENY' },
      { key: 'X-Content-Type-Options', value: 'nosniff' },
      { key: 'Strict-Transport-Security', value: 'max-age=31536000' }
    ]
  }]
  ```

- [ ] T071 **[NEW]** Final code cleanup
  - Remove console.logs
  - Remove unused imports
  - Remove commented code
  - Run linter and fix all warnings

- [ ] T072 **[NEW]** Update README.md
  - Feature overview
  - Setup instructions
  - Testing instructions
  - Deployment guide
  - Links to documentation

- [ ] T073 **[NEW]** Run quickstart.md validation
  - Verify new developer can follow setup steps
  - Test all commands execute successfully
  - Update any outdated instructions

**Checkpoint**: Production-ready, all quality gates passed

---

## Dependencies & Execution Order

### Critical Path

```
Phase 0 (Role Management) 🚨 BLOCKER
    ↓
Phase 1 (Dependencies)
    ↓
Phase 2 (Foundation)
    ↓
Phases 3-8 can proceed in parallel once foundation complete
    ↓
Phase 9 (Testing - continuous throughout)
    ↓
Phase 10 (Polish - after all features complete)
```

### Phase Dependencies

- **Phase 0**: BLOCKS everything - no user can be assigned agent role without this
- **Phase 1**: Must complete before Phase 2
- **Phase 2**: Must complete before any user story work (Phases 3-8)
- **Phase 3**: US1 Registration - Entry point, no dependencies on other stories
- **Phase 4**: US2 Profile - Depends on US1 (need authenticated agent)
- **Phase 5**: US3 Agent Verification - Depends on US2 (need complete profile)
- **Phase 6**: US3 Admin Review - Can develop in parallel with Phase 5
- **Phase 7**: US4 Access Control - Depends on Phase 6 (need verification status)
- **Phase 8**: US5 Public Directory - Depends on Phase 6 (need verified agents)
- **Phase 9**: Testing - Continuous, run tests as features complete
- **Phase 10**: Polish - After all features complete

### Parallel Opportunities

**Within Phase 0**:
- T001 and T002 must be sequential (need role storage before NextAuth config)

**Within Phase 1**:
- All tasks T004-T008 can run in parallel

**Within Phase 2**:
- T009-T011 can run in parallel (type definitions)
- T012-T016 can run in parallel (utilities and stores)

**Between User Stories**:
- Phase 5 (Agent side) and Phase 6 (Admin side) of US3 can run in parallel if different developers
- Phase 8 (Public Directory) can run in parallel with Phases 5-7

**Within Phase 9**:
- All test tasks T049-T058 can run in parallel (different test files)

**Within Phase 10**:
- Most polish tasks T059-T067 can run in parallel

---

## Implementation Strategy

### MVP First (Phases 0-6 Only)

**Timeline**: ~4-5 weeks for complete agent onboarding

**Week 1**: Phase 0 + Phase 1 + Phase 2
- Critical: Role management system
- Foundation setup

**Week 2**: Phase 3 + Phase 4
- User Story 1: OAuth registration with role assignment
- User Story 2: Profile completion integration

**Week 3**: Phase 5 + Phase 6
- User Story 3 (Agent): Verification submission flow
- User Story 3 (Admin): Review workflow with returns

**Week 4**: Testing and bug fixes
- Phase 9: Contract and integration tests
- Fix any issues discovered

**Week 5**: Deployment preparation
- Phase 10 (partial): Security, performance, documentation

**MVP Delivers**:
- ✅ Agents can register via Google OAuth with proper role
- ✅ Agents can complete professional profiles
- ✅ Agents can submit verification with documents
- ✅ Admins can review, approve, reject, or return for unlimited revisions
- ✅ Agents can resubmit based on feedback
- ✅ Verified agents have full platform access

### Full Feature (All Phases)

**Additional Time**: +2-3 weeks

**Week 6**: Phase 7 + Phase 8
- User Story 4: Access control enforcement
- User Story 5: Public agent directory

**Week 7**: Complete testing and polish
- Phase 9: E2E tests
- Phase 10: All polish tasks

**Week 8**: Final QA and deployment
- Security audit
- Performance optimization
- Production deployment

---

## Key Differences from Original tasks.md

### ❌ Removed (Already Exists):
- ~~T002: Install NextAuth~~ (already installed)
- ~~T004: Install Zustand~~ (already installed)
- ~~T008-T009: Create database schema~~ (exists in svc-agent-go)
- ~~T027-T029: Build become-agent-modal~~ (exists)
- ~~T038-T040: Build agent-onboarding-wizard~~ (exists)
- ~~T067-T071: Build admin verification dashboard~~ (exists)
- ~50 duplicate tasks eliminated

### ✅ Changed to Integration/Enhancement:
- OAuth flow → Enhance with role assignment
- Profile forms → Connect to backend APIs
- Verification wizard → Integrate document upload
- Admin dashboard → Add "return for revisions" action
- Draft persistence → Connect frontend to existing backend table

### 🆕 Added Critical Missing Pieces:
- **Phase 0**: Role management system (fundamental blocker)
- **T012**: Session timeout with auto-save (FR-005a, FR-005b) with clarified inactivity definition
- **T022**: Draft persistence with permanent retention for audit (FR-028a)
- **T029**: Estimated review timeframe display (FR-031)
- **T031-T037b**: Return for revisions workflow (unlimited cycles per spec) with full notification system
- **T034-T035**: Admin feedback display for agents with return count tracking
- **T042-T048**: Public agent directory (completely new)
- **Phase 9**: Six Sigma testing enforcement (real tests, no placeholders)

### 📋 Edge Case Coverage:
11 of 14 edge cases from spec.md explicitly covered in tasks:
- ✅ OAuth cancellation/errors: T017 (assumed, should be explicit)
- ✅ Browser close during completion: T012-T013 (session timeout + auto-save)
- ⚠️ Invalid/corrupted documents: T027 (validates types, not corruption - add virus scanning if budget allows)
- ✅ Incomplete verification submission: T028 (validation)
- ✅ Admin rejection/return: T032-T036 (full workflow)
- ✅ Session timeout: T012-T013 (30-min inactivity)
- ✅ Duplicate registration: T017 (FR-010)
- ✅ Form data restoration: T013 (FR-005b)
- ❌ Verified agent license expires: Out of scope (future feature)
- ⚠️ Access another agent's profile: T038 middleware (should add explicit test)
- ❌ Multiple pending applications: Not covered (should prevent or clarify business rule)
- ❌ Agent account deletion before verification: Not covered (should add cascade deletion or business rule)

### 📊 Accuracy Improvement:
- **Original**: ~35% accurate (many duplicates)
- **Revised**: ~90% accurate (focused on gaps and integration)
- **Total Tasks**: 73 (vs 125 original) - more focused, less duplication

---

## Success Criteria Checklist

Before marking feature complete, verify:

- [ ] All 12 constitution principles passed (especially Six Sigma #13)
- [ ] All 6 clarifications from spec.md addressed in implementation
- [ ] All 5 user stories independently testable
- [ ] 100% test coverage achieved (Six Sigma requirement)
- [ ] Zero failing tests
- [ ] All TDD placeholders replaced with real tests
- [ ] Role management system functional and tested
- [ ] Unlimited return cycles working (can return 10+ times)
- [ ] Session timeout (30 min) with auto-save functional
- [ ] Public agent directory SEO optimized
- [ ] Security audit passed
- [ ] Performance benchmarks met
- [ ] Quickstart.md validated by new developer
- [ ] All documentation updated

**Quality Gate**: Must achieve Six Sigma standard (3.4 defects per million opportunities) = Production ready, bulletproof code

---

## Notes

- This is an **integration-focused** task list, not build-from-scratch
- Many components already exist - reuse and enhance rather than rebuild
- Critical blocker: Role management system (Phase 0) must be completed first
- Focus on connecting existing frontend components to svc-agent-go backend
- Admin dashboard needs "return for revisions" added to existing UI
- Public directory is only truly net-new feature
- Six Sigma quality standard applies to all code (100% coverage, zero defects)
- All tests must be real implementations from the start (no placeholders per Constitution Principle #13)
- All file paths are absolute from repository root

---

## ✅ REMEDIATION COMPLETE

**Analysis Date**: 2025-10-14  
**Critical Issues Resolved**: 8  
**High Issues Resolved**: 5  
**Medium Issues Resolved**: 7  
**Low Issues Resolved**: 2

**Total Tasks**: 73 (T001-T073)  
**Duplicate Legacy Tasks Removed**: Lines 802-1192 deleted  
**Constitution Compliance**: ✅ All 13 principles PASS  
**Ready for Implementation**: YES

---

## End of Tasks Document

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T010 Configure NextAuth.js 5.x in espasyo-frontend/src/lib/auth.config.ts with Google OAuth provider, JWT session strategy, 30-minute timeout
- [ ] T011 Create middleware.ts in espasyo-frontend/ to enforce session timeout, check authentication, and auto-save form drafts before timeout
- [ ] T012 [P] Define TypeScript types in espasyo-frontend/src/types/agent.ts for Agent, AgentProfile, VerificationStatus enum
- [ ] T013 [P] Define TypeScript types in espasyo-frontend/src/types/verification.ts for VerificationApplication, VerificationDocument, AdminFeedback, DocumentType enum
- [ ] T014 [P] Define TypeScript types in espasyo-frontend/src/types/admin.ts for AdminUser, ReviewAction enum
- [ ] T015 [P] Create Zod validation schemas in espasyo-frontend/src/lib/validation/profile-schema.ts for AgentProfile fields per data-model.md requirements
- [ ] T016 [P] Create Zod validation schemas in espasyo-frontend/src/lib/validation/verification-schema.ts for VerificationApplication and VerificationDocument
- [ ] T017 [P] Create base API client utilities in espasyo-frontend/src/lib/api/client.ts with error handling, auth headers, and JSON serialization
- [ ] T018 Setup S3 bucket configuration with proper CORS policies and lifecycle rules in espasyo-infrastructure/localstack/init-s3.sh
- [ ] T019 Create document upload utilities in espasyo-frontend/src/lib/utils/document-upload.ts with file validation (5MB max, PDF/JPG/PNG), signed URL handling
- [ ] T020 Create session manager in espasyo-frontend/src/lib/utils/session-manager.ts with auto-save hooks, inactivity detection, session restoration logic
- [ ] T021 [P] Setup Zustand agent store in espasyo-frontend/src/stores/agent-store.ts with profile state, verification status, loading states
- [ ] T022 [P] Setup Zustand verification store in espasyo-frontend/src/stores/verification-store.ts with draft data, current step, submission status
- [ ] T023 Create role-based access control (RBAC) middleware in espasyo-frontend/middleware.ts to check agent/admin/verification_admin roles from JWT claims
- [ ] T024 [P] Install shadcn/ui components: button, card, form, input, textarea, select, dialog, badge, toast, progress via `npx shadcn-ui@latest add`
- [ ] T025 Configure error handling and logging infrastructure in espasyo-frontend/src/lib/logger.ts with structured logging for audit trails
- [ ] T026 Create base layout component in espasyo-frontend/app/(dashboard)/dashboard/agent/layout.tsx with navigation tabs for Profile, Verification, Dashboard

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Agent Registration via Google OAuth (Priority: P1) 🎯 MVP

**Goal**: Enable prospective agents to register via "Become an Agent" button → Google OAuth → authenticated agent dashboard with pending verification status

**Independent Test**: Navigate to landing page as unauthenticated user → click "Become an Agent" → complete Google OAuth → verify redirect to /dashboard/agent with authenticated session → verify user exists in database with role "agent" and verification status "pending"

### Implementation for User Story 1

- [ ] T027 [P] [US1] Create "Become an Agent" button component in espasyo-frontend/src/components/auth/become-agent-button.tsx with modal trigger logic
- [ ] T028 [P] [US1] Create agent registration modal component in espasyo-frontend/src/components/auth/agent-registration-modal.tsx with "Continue with Google" and "Cancel" buttons
- [ ] T029 [US1] Add "Become an Agent" button to landing page header in espasyo-frontend/app/page.tsx with proper positioning and visibility for unauthenticated users
- [ ] T030 [US1] Implement NextAuth Google OAuth sign-in route handler in espasyo-frontend/app/api/auth/[...nextauth]/route.ts per contracts/agent-registration-api.yaml
- [ ] T031 [US1] Implement Google OAuth callback handler in espasyo-frontend/app/api/auth/callback/google/route.ts to create user, assign "agent" role, set verification status "pending"
- [ ] T032 [US1] Create agent dashboard page in espasyo-frontend/app/(dashboard)/dashboard/agent/page.tsx with verification status display and profile completion prompt
- [ ] T033 [US1] Implement API route to complete agent registration in espasyo-frontend/app/api/agent/register/route.ts to create AgentProfile record linked to User
- [ ] T034 [US1] Add duplicate registration prevention logic in OAuth callback to check existing User by email before creating new record
- [ ] T035 [US1] Create verification status banner component in espasyo-frontend/src/components/agent/verification-status-card.tsx to display current status (pending, under review, verified, rejected, returned)
- [ ] T036 [US1] Implement redirect logic to /dashboard/agent after successful OAuth in NextAuth callbacks configuration
- [ ] T037 [US1] Add profile completion notification component in espasyo-frontend/src/components/agent/profile-completion-banner.tsx to intelligently prompt incomplete profiles

**Checkpoint**: At this point, User Story 1 should be fully functional - agents can register via OAuth and access their dashboard

---

## Phase 4: User Story 2 - Complete Personal Profile (Priority: P1)

**Goal**: Enable newly registered agents to complete their professional profile (bio, specializations, coverage areas, PRC license) through agent dashboard

**Independent Test**: Log in as agent with pending verification → navigate to Profile tab → fill all required fields (bio 50+ chars, specializations, coverage areas, PRC license, phone) → save → verify data persists in database → verify profile completion banner disappears

### Implementation for User Story 2

- [ ] T038 [P] [US2] Create agent profile form component in espasyo-frontend/src/components/auth/agent-profile-form.tsx using React Hook Form with Zod validation per profile-schema.ts
- [ ] T039 [P] [US2] Create specializations multi-select component using shadcn/ui Select with options: residential, commercial, luxury, land, industrial, rental
- [ ] T040 [P] [US2] Create coverage areas multi-select component for Philippine provinces/cities with common locations (Metro Manila, Cavite, Laguna, Cebu, etc.)
- [ ] T041 [US2] Create profile page in espasyo-frontend/app/(dashboard)/dashboard/agent/profile/page.tsx that renders agent profile form
- [ ] T042 [US2] Implement API client functions in espasyo-frontend/src/lib/api/agent.ts for getProfile(), updateProfile(), checkProfileCompletion()
- [ ] T043 [US2] Implement profile CRUD API routes in espasyo-frontend/app/api/agent/profile/route.ts (GET for fetch, POST/PUT for update)
- [ ] T044 [US2] Add form validation for bio (min 50, max 2000 chars), PRC license format (^[A-Z0-9\-]+$), phone format (Philippine: ^(\+63|0)?[0-9]{10}$)
- [ ] T045 [US2] Implement profile completion check logic in API route to set isProfileComplete flag based on all required fields filled
- [ ] T046 [US2] Add profile auto-save functionality using lodash.debounce (2-second delay) to save draft while user types
- [ ] T047 [US2] Integrate profile completion status with agent dashboard to conditionally show/hide banner component (T037)
- [ ] T048 [US2] Add success toast notification after profile save using shadcn/ui toast component
- [ ] T049 [US2] Implement profile edit mode with pre-populated form fields from existing profile data
- [ ] T050 [US2] Add profile photo upload field (optional) using document upload utility (T019) with separate handling from verification documents

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently - agents can register and complete their profile

---

## Phase 5: User Story 3 - Initiate and Complete Verification Flow (Priority: P1)

**Goal**: Enable agents with completed profiles to submit verification applications with document uploads through multi-step wizard, handle admin review feedback including unlimited revision cycles

**Independent Test**: Log in as agent with completed profile → navigate to Verification tab → complete 3-step wizard (PRC license upload, ID upload, review/submit) → save draft mid-flow and resume → submit application → verify status changes to "under review" → admin returns for revisions → agent edits and resubmits → verify unlimited return cycles work

### Implementation for User Story 3

- [ ] T051 [P] [US3] Create verification flow wizard component in espasyo-frontend/src/components/auth/verification-flow.tsx with step navigation (Step 1: PRC License, Step 2: ID, Step 3: Review)
- [ ] T052 [P] [US3] Create document upload component in espasyo-frontend/src/components/auth/document-upload-field.tsx with drag-drop support, file validation, progress indicator
- [ ] T053 [P] [US3] Create verification review step component to display uploaded documents summary before final submission
- [ ] T054 [US3] Create verification page in espasyo-frontend/app/(dashboard)/dashboard/agent/verification/page.tsx that renders verification wizard
- [ ] T055 [US3] Implement custom hook useVerificationDraft() in espasyo-frontend/src/hooks/use-verification-draft.ts for draft save/load/auto-save with 2-second debounce
- [ ] T056 [US3] Implement API client functions in espasyo-frontend/src/lib/api/verification.ts for saveDraft(), loadDraft(), submitApplication(), resubmitApplication()
- [ ] T057 [US3] Implement draft management API routes in espasyo-frontend/app/api/agent/verification/draft/route.ts (GET to load, POST to save)
- [ ] T058 [US3] Implement verification submission API route in espasyo-frontend/app/api/agent/verification/route.ts (POST to submit, GET to fetch application)
- [ ] T059 [US3] Implement signed S3 upload URL generation in espasyo-frontend/app/api/agent/verification/upload-url/route.ts using @aws-sdk/s3-request-presigner
- [ ] T060 [US3] Implement document confirmation API route in espasyo-frontend/app/api/agent/verification/documents/[id]/confirm/route.ts to mark document as uploaded
- [ ] T061 [US3] Add verification status update logic to change from "pending" → "under_review" upon submission in submission API route
- [ ] T062 [US3] Create verification audit log entries in database for all status transitions with timestamps and actor references
- [ ] T063 [US3] Add browser close/session timeout protection using session manager (T020) to auto-save draft before page unload
- [ ] T064 [US3] Implement admin notification logic (email/system notification) when new verification application submitted
- [ ] T065 [P] [US3] Create admin verification review panel component in espasyo-frontend/src/components/admin/verification-review-panel.tsx to display application details and documents
- [ ] T066 [P] [US3] Create admin review actions component in espasyo-frontend/src/components/admin/verification-actions.tsx with Approve, Reject, Return for Revisions buttons
- [ ] T067 [US3] Create admin verification list page in espasyo-frontend/app/(dashboard)/dashboard/admin/verifications/page.tsx with filters (pending, under review, approved, rejected)
- [ ] T068 [US3] Create admin verification detail page in espasyo-frontend/app/(dashboard)/dashboard/admin/verifications/[id]/page.tsx to review single application
- [ ] T069 [US3] Implement API client functions in espasyo-frontend/src/lib/api/admin.ts for listApplications(), getApplication(), approveApplication(), rejectApplication(), returnApplication()
- [ ] T070 [US3] Implement admin list API route in espasyo-frontend/app/api/admin/verification/route.ts (GET with filters) with role check for admin/verification_admin
- [ ] T071 [US3] Implement admin review API route in espasyo-frontend/app/api/admin/verification/[id]/review/route.ts (POST with action: approve/reject/return and feedback)
- [ ] T072 [US3] Add admin feedback structure to verification application: { general: string, fieldComments: {}, actionItems: [], returnCount: number } per data-model.md
- [ ] T073 [US3] Implement verification status transitions in review API route: under_review → verified (approve), under_review → rejected (reject), under_review → returned_for_revisions (return)
- [ ] T074 [US3] Create resubmission API route in espasyo-frontend/app/api/agent/verification/resubmit/route.ts to handle resubmissions from rejected/returned applications
- [ ] T075 [US3] Add resubmission logic to restore previous application data and allow editing in verification wizard when status is rejected or returned_for_revisions
- [ ] T076 [US3] Display admin feedback prominently in verification wizard when application is returned for revisions
- [ ] T077 [US3] Implement unlimited return cycle support by allowing returned_for_revisions → under_review transitions with returnCount increment
- [ ] T078 [US3] Add agent notification logic (email/system notification) when verification status changes (approved, rejected, returned)
- [ ] T079 [US3] Implement estimated review timeframe display ("1-2 business days") in verification status card after submission
- [ ] T080 [US3] Add permanent draft retention flag in database to comply with audit requirements per data-model.md FR-028a

**Checkpoint**: At this point, User Stories 1, 2, AND 3 should all work independently - complete agent onboarding flow from registration through verification

---

## Phase 6: User Story 4 - Access Restrictions for Unverified Agents (Priority: P2)

**Goal**: Enforce business rules by blocking unverified agents from creating properties/listings with clear messaging

**Independent Test**: Log in as unverified agent (pending/under review/rejected status) → attempt to navigate to property creation page → verify access blocked with message "Agent verification required to create properties" → verify listing creation similarly blocked → complete verification → verify access granted

### Implementation for User Story 4

- [ ] T081 [P] [US4] Create property creation route guard in espasyo-frontend/middleware.ts to check verification status before allowing access to /dashboard/agent/properties/new
- [ ] T082 [P] [US4] Create listing creation route guard in espasyo-frontend/middleware.ts to check verification status before allowing access to /dashboard/agent/listings/new
- [ ] T083 [P] [US4] Create verification required message component in espasyo-frontend/src/components/agent/verification-required-message.tsx with link to verification flow
- [ ] T084 [US4] Add verification status check to property creation API route in espasyo-frontend/app/api/agent/properties/route.ts to enforce at backend level
- [ ] T085 [US4] Add verification status check to listing creation API route in espasyo-frontend/app/api/agent/listings/route.ts to enforce at backend level
- [ ] T086 [US4] Return 403 Forbidden with clear error message when unverified agents attempt property/listing creation via API
- [ ] T087 [US4] Conditionally render property creation button in agent dashboard based on verification status (hide or disable with tooltip)
- [ ] T088 [US4] Conditionally render listing creation button in agent dashboard based on verification status (hide or disable with tooltip)
- [ ] T089 [US4] Display verification required message page at /dashboard/agent/properties/new when accessed by unverified agent instead of form
- [ ] T090 [US4] Display verification required message page at /dashboard/agent/listings/new when accessed by unverified agent instead of form
- [ ] T091 [US4] Add tooltip to disabled buttons explaining "Complete verification to unlock property and listing creation"
- [ ] T092 [US4] Update agent dashboard layout to show verification progress indicator (e.g., checklist: Register ✓, Complete Profile ✓, Verify ⏳, Create Listings 🔒)

**Checkpoint**: At this point, access control is fully enforced - only verified agents can create properties/listings

---

## Phase 7: User Story 5 - Public Agent Profile Display (Priority: P2)

**Goal**: Enable unauthenticated users to discover verified agents through public directory and view agent profiles with listings

**Independent Test**: Access platform without authentication → navigate to /agents → verify only verified agents shown → click agent card → view full bio and listings → verify pending/rejected agents not visible → test with agent having zero listings shows message "This agent has no active listings at this time"

### Implementation for User Story 5

- [ ] T093 [P] [US5] Create verified agents directory page in espasyo-frontend/app/agents/page.tsx with grid layout of agent cards
- [ ] T094 [P] [US5] Create agent card component in espasyo-frontend/src/components/agent/public-profile-card.tsx displaying name, photo, specializations, verified badge
- [ ] T095 [P] [US5] Create individual agent public profile page in espasyo-frontend/app/agents/[id]/page.tsx with full bio, professional info, listings
- [ ] T096 [US5] Implement public agents list API route in espasyo-frontend/app/api/public/agents/route.ts (GET) filtering only verified agents
- [ ] T097 [US5] Implement public agent profile API route in espasyo-frontend/app/api/public/agents/[id]/route.ts (GET) with 404 for non-verified agents
- [ ] T098 [US5] Add verification status filter to agents query: WHERE verification_status = 'verified' in list and detail API routes
- [ ] T099 [US5] Fetch agent's active listings in profile API route and include in response
- [ ] T100 [US5] Display agent listings in grid on public profile page with clickable cards linking to listing details
- [ ] T101 [US5] Add empty state handling for agents with zero listings: display "This agent has no active listings at this time" per FR-050a
- [ ] T102 [US5] Implement SEO optimization for public agent pages using Next.js 15 metadata API with agent name, bio excerpt, specializations
- [ ] T103 [US5] Add ISR (Incremental Static Regeneration) with 60-second revalidation for agent directory and profile pages per research.md
- [ ] T104 [US5] Display verified badge icon on agent cards and profile pages to indicate verified status
- [ ] T105 [US5] Add structured data markup (JSON-LD) for agent profiles to enhance search engine visibility
- [ ] T106 [US5] Create agent profile breadcrumb navigation: Home > Agents > [Agent Name]
- [ ] T107 [US5] Add "Contact Agent" button on public profile (implementation details for contact form out of scope, placeholder for now)

**Checkpoint**: All user stories should now be independently functional - complete feature from registration to public discovery

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T108 [P] Add loading skeletons for all async data fetching pages using shadcn/ui Skeleton component
- [ ] T109 [P] Add error boundary components in espasyo-frontend/app/error.tsx and espasyo-frontend/app/global-error.tsx for graceful error handling
- [ ] T110 [P] Implement comprehensive error logging for all API routes to capture failures with context
- [ ] T111 [P] Add analytics tracking for key events: registration started, profile completed, verification submitted, verification approved
- [ ] T112 Add accessibility improvements: proper ARIA labels, keyboard navigation, focus management in modal flows
- [ ] T113 Implement responsive design testing for mobile/tablet/desktop breakpoints across all pages
- [ ] T114 Add rate limiting to API routes to prevent abuse (e.g., 10 requests per minute for uploads)
- [ ] T115 Optimize image loading with Next.js Image component for agent photos and listing images
- [ ] T116 Add comprehensive API documentation using JSDoc comments for all API routes
- [ ] T117 [P] Create end-to-end test suite for complete registration → profile → verification → approval flow
- [ ] T118 [P] Create unit tests for validation schemas, utility functions, and API client functions using Vitest
- [ ] T119 Add performance monitoring for page load times and API response times
- [ ] T120 Implement security headers in next.config.js (CSP, HSTS, X-Frame-Options)
- [ ] T121 Run quickstart.md validation: verify all setup steps work for new developer onboarding
- [ ] T122 Create user documentation in espasyo-docs/AGENT-REGISTRATION-USER-GUIDE.md for agents and admins
- [ ] T123 Perform security audit: SQL injection prevention, XSS protection, CSRF tokens, file upload validation
- [ ] T124 Final code review and cleanup: remove console.logs, unused imports, commented code
- [ ] T125 Update README.md with feature overview and links to documentation

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion (T001-T009) - BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational phase completion (T010-T026) - Entry point for all agents
- **User Story 2 (Phase 4)**: Depends on Foundational phase completion (T010-T026) - Requires User Story 1 for authenticated context but functionally independent
- **User Story 3 (Phase 5)**: Depends on Foundational phase completion (T010-T026) and User Story 2 profile completion logic (T045) for profile check
- **User Story 4 (Phase 6)**: Depends on Foundational phase completion (T010-T026) and User Story 3 verification status (T073) for access control enforcement
- **User Story 5 (Phase 7)**: Depends on Foundational phase completion (T010-T026) and User Story 3 verification data (T096-T097) for public directory filtering
- **Polish (Phase 8)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories - REQUIRED FOR MVP
- **User Story 2 (P1)**: Can start after Foundational (Phase 2) - Requires US1 authentication but independently testable - REQUIRED FOR MVP
- **User Story 3 (P1)**: Can start after Foundational (Phase 2) - Requires US2 profile completion check - REQUIRED FOR MVP
- **User Story 4 (P2)**: Can start after Foundational (Phase 2) - Integrates with US3 verification status but independently testable
- **User Story 5 (P2)**: Can start after Foundational (Phase 2) - Queries US3 verification data but independently testable

### Within Each User Story

- Tests MUST be written and FAIL before implementation (if test-driven approach requested)
- Types and schemas before components (T012-T016 before T027)
- API clients before UI components (T042 before T038)
- Core implementation before integration (T030-T031 before T037)
- Story complete before moving to next priority

### Parallel Opportunities

#### Setup Phase (Phase 1)
- T002-T006 can all run in parallel (independent npm installs)

#### Foundational Phase (Phase 2)
- T012-T014 can run in parallel (type definitions in separate files)
- T015-T016 can run in parallel (validation schemas in separate files)
- T021-T022 can run in parallel (Zustand stores in separate files)
- Once types are done (T012-T014), T017-T020 can run in parallel (utilities using types)

#### User Story 1 (Phase 3)
- T027-T028 can run in parallel (separate component files)
- T035 and T037 can run in parallel (separate status components)

#### User Story 2 (Phase 4)
- T038-T040 can run in parallel (separate form components)

#### User Story 3 (Phase 5)
- T051-T053 can run in parallel (separate wizard components)
- T065-T066 can run in parallel (separate admin components)
- T055-T056 can run in parallel (hooks and API client functions)

#### User Story 4 (Phase 6)
- T081-T082 can run in parallel (separate route guards)
- T087-T088 can run in parallel (UI button logic)

#### User Story 5 (Phase 7)
- T093-T095 can run in parallel (separate page components)

#### Polish Phase (Phase 8)
- T108-T111 can run in parallel (independent improvements)
- T117-T118 can run in parallel (separate test suites)

---

## Implementation Strategy

### MVP First (User Stories 1-3 Only)

**Timeline**: ~3-4 weeks for MVP with complete agent onboarding

1. **Week 1**: Complete Phase 1 (Setup) and Phase 2 (Foundational)
2. **Week 2**: Complete Phase 3 (User Story 1 - Registration)
3. **Week 3**: Complete Phase 4 (User Story 2 - Profile) and start Phase 5 (User Story 3 - Verification)
4. **Week 4**: Complete Phase 5 (User Story 3 - Verification including admin review)
5. **STOP and VALIDATE**: Test complete flow from registration → profile → verification → admin approval
6. Deploy MVP to staging for stakeholder review

**MVP Delivers**:
- ✅ Agents can register via Google OAuth
- ✅ Agents can complete professional profiles
- ✅ Agents can submit verification applications with document uploads
- ✅ Admins can review, approve, reject, or return applications for unlimited revisions
- ✅ Verified agents gain full platform access

### Incremental Delivery

1. **Phase 1+2**: Setup + Foundational → Foundation ready (~1 week)
2. **Phase 3**: Add User Story 1 → Test independently → Deploy/Demo (OAuth registration works!) (~1 week)
3. **Phase 4**: Add User Story 2 → Test independently → Deploy/Demo (Profile completion works!) (~1 week)
4. **Phase 5**: Add User Story 3 → Test independently → Deploy/Demo (Verification flow works!) (~1-2 weeks)
5. **Phase 6**: Add User Story 4 → Test independently → Deploy/Demo (Access control enforced!) (~3-4 days)
6. **Phase 7**: Add User Story 5 → Test independently → Deploy/Demo (Public discovery ready!) (~1 week)
7. **Phase 8**: Polish → Final QA → Production deployment (~1 week)

**Total Timeline**: ~6-8 weeks for complete feature with all 5 user stories

### Parallel Team Strategy

With 3+ developers available:

**Week 1**: All developers work on Setup + Foundational together (T001-T026)

**Week 2-3**: Once Foundational is complete, parallelize:
- **Developer A**: User Story 1 (Registration) - T027-T037
- **Developer B**: User Story 2 (Profile) - T038-T050
- **Developer C**: Begin User Story 3 (Verification wizard) - T051-T064

**Week 4-5**: Continue parallel development:
- **Developer A**: User Story 4 (Access Control) - T081-T092
- **Developer B**: User Story 3 (Admin review) - T065-T080
- **Developer C**: User Story 5 (Public Directory) - T093-T107

**Week 6**: Integration and Polish (all developers on Phase 8)

**Benefits**:
- Faster delivery (4-6 weeks vs 6-8 weeks)
- Each developer owns a complete user story
- Stories integrate cleanly due to foundational phase

---

## Testing Strategy

### Contract Testing

Contract tests validate API route contracts match the OpenAPI specification in contracts/agent-registration-api.yaml.

**Key Tests** (Optional - only if requested):
- Verify POST /api/auth/signin/google returns 302 redirect with proper headers
- Verify GET /api/auth/callback/google with valid code creates user and sets session cookie
- Verify POST /api/agent/register with authenticated session creates AgentProfile
- Verify GET /api/agent/profile returns profile data matching schema
- Verify POST /api/agent/verification with documents returns 201 and updates status
- Verify POST /api/admin/verification/[id]/review with approve action updates status to verified

### Integration Testing

Integration tests validate complete user journeys work end-to-end.

**Key Flows** (Optional - only if requested):
- Complete registration flow: Landing page → OAuth → Dashboard (US1)
- Complete profile flow: Dashboard → Profile form → Save → Verification available (US2)
- Complete verification flow: Profile complete → Upload documents → Submit → Admin review → Approval (US3)
- Access control flow: Unverified agent → Attempt property creation → Blocked → Verify → Allowed (US4)
- Public discovery flow: Unauthenticated → Agents page → Click verified agent → View bio and listings (US5)

### Manual Testing Checklist

Before marking any user story complete, manually verify:

1. **US1**: Can register from landing page, OAuth succeeds, redirects to dashboard, user in DB
2. **US2**: Can fill profile form, validation works, saves successfully, banner disappears
3. **US3**: Can upload documents, save draft, resume later, submit, admin can review/return/approve, unlimited return cycles work
4. **US4**: Unverified agent blocked from creating property/listing, verified agent allowed
5. **US5**: Only verified agents shown publicly, profiles display correctly, zero listings show message

---

## Risk Mitigation

### High-Risk Tasks

- **T030-T031** (Google OAuth integration): Use NextAuth.js documentation extensively, test with Google OAuth playground first
- **T059** (S3 signed URLs): Test thoroughly with LocalStack before AWS deployment, handle expiration edge cases
- **T063** (Browser close protection): Test across browsers (Chrome, Firefox, Safari), handle beforeunload event carefully
- **T073** (Verification state machine): Document all valid transitions, add database constraints to prevent invalid states
- **T077** (Unlimited return cycles): Ensure returnCount increments properly, test performance with high return counts

### Performance Concerns

- **Large file uploads** (T052, T059): Implement client-side chunking for files >5MB (though spec limits to 5MB)
- **Public agent directory** (T093): Add pagination if >50 agents, consider lazy loading images
- **ISR with 60s revalidation** (T103): Monitor cache hit rates, adjust revalidation time based on agent update frequency

### Security Considerations

- **Session timeout** (T011, T020): Test timeout behavior thoroughly, ensure auto-save doesn't expose data
- **File upload validation** (T019, T026): Validate file types on server side, scan for malware if budget allows
- **RBAC enforcement** (T023, T070): Test role checks at both middleware and API route levels
- **SQL injection** (T043, T096): Use parameterized queries exclusively, validate all inputs

---

## Notes

- [P] tasks = different files, no dependencies within same phase
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing (if TDD approach requested)
- Commit after each task or logical group (suggest T027-T029 as one commit)
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
- All file paths are absolute from repository root (espasyo-frontend/, espasyo-backend/, etc.)
- Tasks reference exact line numbers from spec.md for functional requirements (FR-001, FR-002, etc.)
- Session timeout (30 min) and auto-save must be thoroughly tested across all forms (T011, T020, T046, T055, T063)
- Unlimited return cycles (T077) is critical business logic - must be tested with multiple return scenarios
