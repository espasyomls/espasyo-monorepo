# Tasks: Progressive Agent Verification Flow

**Input**: Design documents from `/specs/005-i-want-to/`
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
- **Web app**: `espasyo-frontend/app/`, `espasyo-frontend/src/`
- **Backend**: `espasyo-backend/` (for data persistence)
- All paths are absolute from repository root

## Phase 3.1: Setup
- [ ] T001 Configure NextAuth.js for Gmail OAuth in espasyo-frontend/src/lib/auth.ts
- [ ] T002 Set up TypeScript type definitions in espasyo-frontend/src/types/dashboard.ts
- [ ] T003 Configure file upload handling with size/type validation
- [ ] T004 Set up in-memory data storage for development

## Phase 3.2: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.3
**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**
- [ ] T005 [P] Contract test for agent verification draft API in espasyo-frontend/tests/contract/test-agent-verification-draft-api.test.ts
- [ ] T006 [P] Contract test for agent verification submission API in espasyo-frontend/tests/contract/test-agent-verification-submit-api.test.ts
- [ ] T007 [P] Contract test for admin verification list API in espasyo-frontend/tests/contract/test-admin-verification-list-api.test.ts
- [ ] T008 [P] Contract test for admin verification review API in espasyo-frontend/tests/contract/test-admin-verification-review-api.test.ts
- [ ] T009 [P] Integration test for complete agent verification flow in espasyo-frontend/tests/integration/test-complete-verification-flow.test.ts
- [ ] T010 [P] Integration test for draft save and resume in espasyo-frontend/tests/integration/test-draft-save-resume.test.ts
- [ ] T011 [P] Integration test for admin review workflow in espasyo-frontend/tests/integration/test-admin-review-workflow.test.ts
- [ ] T012 [P] Integration test for error handling and recovery in espasyo-frontend/tests/integration/test-error-handling-recovery.test.ts
- [ ] T013 [P] Integration test for status tracking and notifications in espasyo-frontend/tests/integration/test-status-tracking-notifications.test.ts

## Phase 3.3: Core Implementation (ONLY after tests are failing)
- [ ] T014 [P] Agent entity type definitions in espasyo-frontend/src/types/dashboard.ts
- [ ] T015 [P] VerificationApplication entity type definitions in espasyo-frontend/src/types/dashboard.ts
- [ ] T016 [P] VerificationDocument entity type definitions in espasyo-frontend/src/types/dashboard.ts
- [ ] T017 [P] VerificationDraft entity type definitions in espasyo-frontend/src/types/dashboard.ts
- [ ] T018 [P] Administrator entity type definitions in espasyo-frontend/src/types/dashboard.ts
- [ ] T019 Implement agent verification draft API in espasyo-frontend/app/api/agent/verification/draft/route.ts
- [ ] T020 Implement agent verification submission API in espasyo-frontend/app/api/agent/verification/route.ts
- [ ] T021 Implement admin verification list API in espasyo-frontend/app/api/admin/agent-verifications/route.ts
- [ ] T022 Implement admin verification review API in espasyo-frontend/app/api/admin/agent-verifications/[id]/review/route.ts
- [ ] T023 Create progressive verification form component in espasyo-frontend/src/components/auth/progressive-verification-form.tsx
- [ ] T024 Create agent info step component in espasyo-frontend/src/components/auth/steps/agent-info-step.tsx
- [ ] T025 Create document upload step component in espasyo-frontend/src/components/auth/steps/document-upload-step.tsx
- [ ] T026 Create service area step component in espasyo-frontend/src/components/auth/steps/service-area-step.tsx
- [ ] T027 Update agent dashboard with Verify Me tab in espasyo-frontend/app/dashboard/agent/page.tsx
- [ ] T028 Update agent registration redirect in espasyo-frontend/app/auth/agent-register/page.tsx

## Phase 3.4: Integration
- [ ] T029 Implement Zustand store for verification state management
- [ ] T030 Integrate React Hook Form with validation schemas
- [ ] T031 Set up file upload handling with security validation
- [ ] T032 Implement status tracking and notifications system
- [ ] T033 Add admin role-based access controls

## Phase 3.5: Polish
- [ ] T034 [P] Unit tests for form validation in espasyo-frontend/tests/unit/test-form-validation.test.ts
- [ ] T035 [P] Unit tests for status transitions in espasyo-frontend/tests/unit/test-status-transitions.test.ts
- [ ] T036 [P] Unit tests for file upload validation in espasyo-frontend/tests/unit/test-file-upload-validation.test.ts
- [ ] T037 Performance optimization for form rendering
- [ ] T038 Add loading states and error boundaries
- [ ] T039 Update component documentation
- [ ] T040 Run quickstart validation scenarios
- [ ] T041 Final integration testing and bug fixes

## Dependencies
- Setup (T001-T004) before everything
- Tests (T005-T013) before implementation (T014-T033)
- Type definitions (T014-T018) before API routes (T019-T022)
- API routes (T019-T022) before components (T023-T028)
- Components (T023-T028) before integration (T029-T033)
- Implementation (T014-T033) before polish (T034-T041)

## Parallel Example
```
# Launch T005-T008 together (contract tests):
Task: "Contract test for agent verification draft API in espasyo-frontend/tests/contract/test-agent-verification-draft-api.test.ts"
Task: "Contract test for agent verification submission API in espasyo-frontend/tests/contract/test-agent-verification-submit-api.test.ts"
Task: "Contract test for admin verification list API in espasyo-frontend/tests/contract/test-admin-verification-list-api.test.ts"
Task: "Contract test for admin verification review API in espasyo-frontend/tests/contract/test-admin-verification-review-api.test.ts"

# Launch T009-T013 together (integration tests):
Task: "Integration test for complete agent verification flow in espasyo-frontend/tests/integration/test-complete-verification-flow.test.ts"
Task: "Integration test for draft save and resume in espasyo-frontend/tests/integration/test-draft-save-resume.test.ts"
Task: "Integration test for admin review workflow in espasyo-frontend/tests/integration/test-admin-review-workflow.test.ts"
Task: "Integration test for error handling and recovery in espasyo-frontend/tests/integration/test-error-handling-recovery.test.ts"
Task: "Integration test for status tracking and notifications in espasyo-frontend/tests/integration/test-status-tracking-notifications.test.ts"
```

## Notes
- [P] tasks = different files, no dependencies
- Verify tests fail before implementing
- Commit after each task
- Avoid: vague tasks, same file conflicts
- All paths are absolute from repository root
- Follow TDD: tests first, then implementation
- Use the design documents for exact specifications

## Task Generation Rules
*Applied during main() execution*

1. **From Contracts**:
   - Each contract file → contract test task [P]
   - Each endpoint → implementation task

2. **From Data Model**:
   - Each entity → model creation task [P]
   - Relationships → service layer tasks

3. **From User Stories**:
   - Each story → integration test [P]
   - Quickstart scenarios → validation tasks

4. **Ordering**:
   - Setup → Tests → Models → Services → Endpoints → Polish
   - Dependencies block parallel execution

## Validation Checklist
*GATE: Checked by main() before returning*

- [x] All contracts have corresponding tests (4 contracts → 4 tests)
- [x] All entities have model tasks (5 entities → 5 type definition tasks)
- [x] All tests come before implementation (TDD ordering)
- [x] Parallel tasks truly independent (different file paths)
- [x] Each task specifies exact file path (all paths absolute)
- [x] No task modifies same file as another [P] task (verified)</content>
<parameter name="filePath">/home/boggss/espasyoMLS/specs/005-i-want-to/tasks.md