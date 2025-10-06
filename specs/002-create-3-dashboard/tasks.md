# Tasks: Create 3 Dashboard Pages

**Input**: Design documents from `/specs/002-create-3-dashboard/`
**Prerequisites**: plan.md (required), research.md, data-model.md, contracts/

## Execution Flow (main)
```
1. Load plan.md from feature directory
   → If not found: ERROR "No implementation plan found"
   → Extract: tech stack, libraries, structure
2. Load optional design documents:
   → data-model.md: Extract entities → model tasks
   → contracts/: Each file → contract test task
   → research.md: Extract decisions → setup tasks
3. Generate tasks by category:
   → Setup: project init, dependencies, linting
   → Tests: contract tests, integration tests
   → Core: models, services, CLI commands
   → Integration: DB, middleware, logging
   → Polish: unit tests, performance, docs
4. Apply task rules:
   → Different files = mark [P] for parallel
   → Same file = sequential (no [P])
   → Tests before implementation (TDD)
5. Number tasks sequentially (T001, T002...)
6. Generate dependency graph
7. Create parallel execution examples
8. Validate task completeness:
   → All contracts have tests?
   → All entities have models?
   → All endpoints implemented?
9. Return: SUCCESS (tasks ready for execution)
```

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths in descriptions

## Path Conventions
- **Web app**: `espasyo-frontend/` for frontend components
- **Backend**: `espasyo-backend/` for API endpoints
- Paths shown below follow the project structure from plan.md

## Phase 3.1: Setup
- [x] T001 Create dashboard directory structure in espasyo-frontend/app/dashboard/
- [x] T002 Install required dependencies (Zustand stores, additional shadcn/ui components)
- [x] T003 [P] Configure TypeScript types for dashboard entities in espasyo-frontend/types/dashboard.ts
- [x] T004 [P] Set up middleware for role-based routing in espasyo-frontend/middleware.ts

## Phase 3.2: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.3
**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**
- [ ] T005 [P] Contract test GET /api/dashboard/{role} in espasyo-frontend/__tests__/contract/test-dashboard-role.contract.test.ts
- [ ] T006 [P] Contract test GET /api/dashboard/{role}/metrics in espasyo-frontend/__tests__/contract/test-dashboard-metrics.contract.test.ts
- [ ] T007 [P] Contract test GET /api/user/role in espasyo-frontend/__tests__/contract/test-user-role.contract.test.ts
- [ ] T008 [P] Contract test PUT /api/user/role in espasyo-frontend/__tests__/contract/test-user-role-update.contract.test.ts
- [ ] T009 [P] Contract test GET /api/user/preferences in espasyo-frontend/__tests__/contract/test-user-preferences.contract.test.ts
- [ ] T010 [P] Contract test PUT /api/user/preferences in espasyo-frontend/__tests__/contract/test-user-preferences-update.contract.test.ts
- [ ] T011 [P] Integration test administrator dashboard access in espasyo-frontend/__tests__/integration/test-admin-dashboard.integration.test.ts
- [ ] T012 [P] Integration test agent dashboard access in espasyo-frontend/__tests__/integration/test-agent-dashboard.integration.test.ts
- [ ] T013 [P] Integration test user dashboard access in espasyo-frontend/__tests__/integration/test-user-dashboard.integration.test.ts
- [ ] T014 [P] Integration test unauthorized access handling in espasyo-frontend/__tests__/integration/test-unauthorized-access.integration.test.ts
- [ ] T015 [P] Integration test role-based navigation in espasyo-frontend/__tests__/integration/test-role-navigation.integration.test.ts

## Phase 3.3: Core Implementation (ONLY after tests are failing)
- [x] T016 [P] User entity types in espasyo-frontend/types/user.ts
- [x] T017 [P] UserRole entity types in espasyo-frontend/types/role.ts
- [x] T018 [P] Dashboard entity types in espasyo-frontend/types/dashboard.ts
- [x] T019 [P] Dashboard Zustand store in espasyo-frontend/lib/stores/dashboard-store.ts
- [x] T020 [P] User preferences Zustand store in espasyo-frontend/lib/stores/preferences-store.ts
- [x] T021 [P] Role-based navigation component in espasyo-frontend/components/dashboard/navigation.tsx
- [x] T022 [P] Dashboard widget base component in espasyo-frontend/components/dashboard/widget.tsx
- [x] T023 [P] Metric display component in espasyo-frontend/components/dashboard/metric.tsx
- [x] T024 Admin dashboard page in espasyo-frontend/app/dashboard/admin/page.tsx
- [x] T025 Agent dashboard page in espasyo-frontend/app/dashboard/agent/page.tsx
- [x] T026 User dashboard page in espasyo-frontend/app/dashboard/user/page.tsx
- [x] T027 GET /api/dashboard/[role] API route in espasyo-frontend/app/api/dashboard/[role]/route.ts
- [x] T028 GET /api/dashboard/[role]/metrics API route in espasyo-frontend/app/api/dashboard/[role]/metrics/route.ts
- [x] T029 GET /api/user/role API route in espasyo-frontend/app/api/user/role/route.ts
- [x] T030 PUT /api/user/role API route in espasyo-frontend/app/api/user/role/route.ts
- [x] T031 GET /api/user/preferences API route in espasyo-frontend/app/api/user/preferences/route.ts
- [x] T032 PUT /api/user/preferences API route in espasyo-frontend/app/api/user/preferences/route.ts

## Phase 3.4: Integration
- [x] T033 Extend NextAuth session with role information in espasyo-frontend/lib/auth.ts
- [x] T034 Implement role-based middleware logic in espasyo-frontend/middleware.ts
- [x] T035 Connect dashboard stores to API routes
- [x] T036 Add error boundaries for dashboard components
- [x] T037 Implement loading states for dashboard widgets
- [ ] T038 Implement mobile phone verification workflow in espasyo-frontend/components/auth/PhoneVerification.tsx
- [ ] T039 Create SMS verification service integration in espasyo-frontend/lib/sms-verification.ts
- [ ] T040 Build agent verification submission form with document upload in espasyo-frontend/components/auth/AgentVerificationForm.tsx
- [ ] T041 Add identity document validation and upload in espasyo-frontend/lib/document-validation.ts
- [ ] T042 Implement agent verification API with document handling in espasyo-frontend/app/api/agent/verification/route.ts
- [ ] T043 Create admin agent verification dashboard in espasyo-frontend/app/dashboard/admin/agents/verification/page.tsx
- [ ] T044 Build admin document review interface with approval/decline in espasyo-frontend/components/admin/AgentVerificationReview.tsx
- [ ] T045 Add admin request for additional documents feature in espasyo-frontend/components/admin/AdditionalDocumentRequest.tsx
- [ ] T046 Implement 24-hour resubmission cooldown logic in espasyo-frontend/lib/verification-cooldown.ts
- [ ] T047 Create agent verification status tracking with resubmission timer in espasyo-frontend/components/dashboard/AgentVerificationStatus.tsx
- [ ] T048 Add verification notification system for status updates in espasyo-frontend/lib/verification-notifications.ts
- [ ] T049 Implement admin-only approval authority checks in espasyo-frontend/middleware/admin-only.ts
- [x] T050 Implement bulk selection checkboxes for agent verification applications in espasyo-frontend/app/dashboard/admin/agents/verification/page.tsx
- [x] T051 Create bulk approve confirmation dialog component in espasyo-frontend/components/admin/BulkApproveDialog.tsx
- [x] T052 Create bulk decline confirmation dialog component in espasyo-frontend/components/admin/BulkDeclineDialog.tsx
- [x] T053 Implement POST /api/admin/agents/verification/bulk-approve API endpoint in espasyo-frontend/app/api/admin/agents/verification/bulk-approve/route.ts
- [x] T054 Implement POST /api/admin/agents/verification/bulk-decline API endpoint in espasyo-frontend/app/api/admin/agents/verification/bulk-decline/route.ts
- [x] T055 Connect bulk actions UI to API endpoints with error handling
- [x] T056 Create integration test for bulk actions functionality in espasyo-frontend/__tests__/integration/test-bulk-actions.integration.test.ts
- [ ] T057 Create agent compliance and renewal tracking in espasyo-frontend/app/dashboard/agent/compliance/page.tsx
- [ ] T058 Connect phone verification to agent onboarding flow
- [ ] T059 Add document submission validation before API submission
- [ ] T060 Implement admin additional document request workflow
- [ ] T061 Create declined application resubmission interface
- [ ] T062 Implement verification audit trail for admin review history

## Phase 3.5: Polish
- [ ] T063 [P] Unit tests for dashboard components in espasyo-frontend/__tests__/unit/test-dashboard-components.unit.test.ts
- [ ] T064 [P] Unit tests for Zustand stores in espasyo-frontend/__tests__/unit/test-stores.unit.test.ts
- [ ] T065 Performance optimization (<2s load time)
- [ ] T066 Mobile responsiveness testing (375px, 768px, 1440px viewports)
- [ ] T067 [P] Update component documentation in espasyo-frontend/components/dashboard/README.md
- [ ] T068 Remove code duplication across dashboard components
- [ ] T069 Run quickstart.md validation scenarios

## Dependencies
- Setup (T001-T004) before all other tasks
- Tests (T005-T015) before implementation (T016-T062)
- T016-T018 blocks T019-T020 (types before stores)
- T019-T020 blocks T021-T023 (stores before components)
- T021-T023 blocks T024-T026 (components before pages)
- T016-T018 blocks T027-T032 (types before API routes)
- T033 blocks T034 (auth extension before middleware)
- T016-T018 blocks T038-T062 (types before agent verification system)
- T038-T039 blocks T040-T042 (phone verification before document submission)
- T040-T042 blocks T043 (document validation before admin review)
- T043 blocks T044-T046 (API before admin review and cooldown)
- T044 blocks T045, T053 (review interface before additional requests)
- T046 blocks T054 (cooldown logic before resubmission interface)
- T049 blocks T044-T045 (admin authority before approval actions)
- Bulk actions (T050-T056) depend on admin dashboard (T024) and agent verification API (T043)
- Implementation (T016-T062) before polish (T063-T069)

## Parallel Execution Examples

**Setup Phase (T001-T004):**
```
Task: "Create dashboard directory structure in espasyo-frontend/app/dashboard/"
Task: "Install required dependencies (Zustand stores, additional shadcn/ui components)"
Task: "Configure TypeScript types for dashboard entities in espasyo-frontend/types/dashboard.ts"
Task: "Set up middleware for role-based routing in espasyo-frontend/middleware.ts"
```

**Contract Tests (T005-T010):**
```
Task: "Contract test GET /api/dashboard/{role} in espasyo-frontend/__tests__/contract/test-dashboard-role.contract.test.ts"
Task: "Contract test GET /api/dashboard/{role}/metrics in espasyo-frontend/__tests__/contract/test-dashboard-metrics.contract.test.ts"
Task: "Contract test GET /api/user/role in espasyo-frontend/__tests__/contract/test-user-role.contract.test.ts"
Task: "Contract test PUT /api/user/role in espasyo-frontend/__tests__/contract/test-user-role-update.contract.test.ts"
Task: "Contract test GET /api/user/preferences in espasyo-frontend/__tests__/contract/test-user-preferences.contract.test.ts"
Task: "Contract test PUT /api/user/preferences in espasyo-frontend/__tests__/contract/test-user-preferences-update.contract.test.ts"
```

**Entity Types (T016-T018):**
```
Task: "User entity types in espasyo-frontend/types/user.ts"
Task: "UserRole entity types in espasyo-frontend/types/role.ts"
Task: "Dashboard entity types in espasyo-frontend/types/dashboard.ts"
```

**Dashboard Pages (T024-T026):**
```
Task: "Admin dashboard page in espasyo-frontend/app/dashboard/admin/page.tsx"
Task: "Agent dashboard page in espasyo-frontend/app/dashboard/agent/page.tsx"
Task: "User dashboard page in espasyo-frontend/app/dashboard/user/page.tsx"
```

**Agent Verification Components (T038-T042):**
```
Task: "Implement mobile phone verification workflow in espasyo-frontend/components/auth/PhoneVerification.tsx"
Task: "Create SMS verification service integration in espasyo-frontend/lib/sms-verification.ts"
Task: "Build agent verification submission form with document upload in espasyo-frontend/components/auth/AgentVerificationForm.tsx"
Task: "Add identity document validation and upload in espasyo-frontend/lib/document-validation.ts"
Task: "Implement agent verification API with document handling in espasyo-frontend/app/api/agent/verification/route.ts"
```

## Notes
- [P] tasks = different files, no dependencies, can run in parallel
- All contract tests MUST fail initially (red) before implementation begins
- Commit after each completed task for proper git history
- Verify middleware.ts exists and is functional before dashboard pages
- Ensure all API routes follow Next.js 15 App Router conventions
- Test mobile responsiveness on actual devices, not just browser dev tools
- Agent verification requires phone verification before document submission
- Administrator has sole authority for agent approval decisions
- Declined agent applications have 24-hour resubmission cooldown
- Admin can request additional documents during review process
- SMS verification service integration required for phone verification
- Bulk actions allow administrators to approve/decline multiple applications simultaneously
- Bulk actions include confirmation dialogs to prevent accidental operations

## Task Generation Rules Applied
- ✅ Each contract file → contract test task marked [P]
- ✅ Each entity from data-model.md → type/model task marked [P]
- ✅ Each endpoint from contracts/ → API route implementation task
- ✅ Each user story from quickstart.md → integration test marked [P]
- ✅ Agent verification workflow → comprehensive task breakdown (T038-T062)
- ✅ Phone verification prerequisite → dedicated tasks (T038-T039)
- ✅ Document submission and validation → specialized tasks (T040-T042)
- ✅ Admin review and approval → authority-restricted tasks (T043-T049)
- ✅ 24-hour resubmission cooldown → business logic tasks (T046, T061)
- ✅ Bulk actions functionality → dedicated tasks (T050-T056)
- ✅ Bulk selection UI → checkbox implementation (T050)
- ✅ Confirmation dialogs → safety-first approach (T051-T052)
- ✅ Bulk API endpoints → RESTful design (T053-T054)
- ✅ UI-API integration → error handling included (T055)
- ✅ Integration testing → end-to-end validation (T056)
- ✅ Different files = marked [P] for parallel execution
- ✅ Same file = sequential (no [P])
- ✅ Tests before implementation (TDD approach)
- ✅ Dependencies clearly documented</content>
<parameter name="filePath">/home/boggss/espasyoMLS/specs/002-create-3-dashboard/tasks.md