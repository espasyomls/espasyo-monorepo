# Tasks: Create the Landing Page

**Input**: Design documents from `/specs/001-create-the-landing/`
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
- Paths adjusted for Next.js frontend structure

## Phase 3.1: Setup
- [x] T001 Configure Google OAuth credentials and environment variables in espasyo-frontend/.env.local
- [x] T002 Install required dependencies (NextAuth.js, Zustand) in espasyo-frontend/package.json
- [x] T003 [P] Configure NextAuth.js for Google OAuth in espasyo-frontend/src/lib/auth.ts

## Phase 3.2: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.3
**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**
- [x] T004 [P] Contract test for Google OAuth signin endpoint in espasyo-frontend/__tests__/contracts/test-google-oauth-signin.test.ts
- [x] T005 [P] Contract test for Google OAuth callback endpoint in espasyo-frontend/__tests__/contracts/test-google-oauth-callback.test.ts
- [x] T006 [P] Integration test for landing page display in espasyo-frontend/__tests__/integration/test-landing-page.test.ts
- [x] T007 [P] Integration test for login modal opening in espasyo-frontend/__tests__/integration/test-login-modal.test.ts
- [x] T008 [P] Integration test for registration modal opening in espasyo-frontend/__tests__/integration/test-registration-modal.test.ts

## Phase 3.3: Core Implementation (ONLY after tests are failing)
- [x] T009 Create header component with auth buttons in espasyo-frontend/src/components/layout/Header.tsx
- [x] T010 Create login modal component using shadcn/ui in espasyo-frontend/src/components/auth/LoginModal.tsx
- [x] T011 Create registration modal component using shadcn/ui in espasyo-frontend/src/components/auth/RegistrationModal.tsx
- [x] T012 Create landing page hero section in espasyo-frontend/app/page.tsx
- [x] T013 Create property listings display component in espasyo-frontend/src/components/PropertyListings.tsx
- [x] T014 Implement Zustand auth store in espasyo-frontend/src/stores/auth.ts
- [x] T015 Integrate Google OAuth with NextAuth.js in espasyo-frontend/src/lib/auth.ts

## Phase 3.4: Integration
- [x] T016 Connect auth store to header and modal components
- [x] T017 Add mobile responsiveness and touch optimizations
- [x] T018 Implement conditional header rendering based on auth state

## Phase 3.5: Polish
- [x] T019 [P] Unit tests for header component in espasyo-frontend/__tests__/unit/test-header.test.ts
- [x] T020 [P] Unit tests for auth modals in espasyo-frontend/__tests__/unit/test-modals.test.ts
- [x] T021 Performance optimization for landing page load time
- [x] T022 [P] Update README.md with landing page documentation
- [x] T023 Accessibility audit and fixes for mobile users
- [x] T024 [P] Accessibility audit for modals in espasyo-frontend/__tests__/accessibility/test-modals-accessibility.test.ts

## Phase 4: Validation
- [x] T025 Run all tests to ensure TDD compliance
- [x] T026 Validate mobile responsiveness
- [x] T027 Check OAuth flow integration

## Phase 5: Completion
- [x] T028 Update project documentation
- [x] T029 Commit changes with proper message
- [x] T030 Prepare for deployment

## Dependencies
- Setup (T001-T003) before tests (T004-T008)
- Tests (T004-T008) before implementation (T009-T015)
- T014 blocks T016
- T009-T011 blocks T017
- Implementation before polish (T019-T023)

## Parallel Example
```
# Launch T004-T008 together:
Task: "Contract test for Google OAuth signin endpoint in espasyo-frontend/__tests__/contracts/test-google-oauth-signin.test.ts"
Task: "Contract test for Google OAuth callback endpoint in espasyo-frontend/__tests__/contracts/test-google-oauth-callback.test.ts"
Task: "Integration test for landing page display in espasyo-frontend/__tests__/integration/test-landing-page.test.ts"
Task: "Integration test for login modal opening in espasyo-frontend/__tests__/integration/test-login-modal.test.ts"
Task: "Integration test for registration modal opening in espasyo-frontend/__tests__/integration/test-registration-modal.test.ts"
```

## Notes
- [P] tasks = different files, no dependencies
- Verify tests fail before implementing
- Commit after each task
- Avoid: vague tasks, same file conflicts

## Task Generation Rules
*Applied during main() execution*

1. **From Contracts**:
   - google-oauth.contract.md → T004, T005 contract test tasks [P]
   
2. **From Data Model**:
   - No entities → no model tasks
   
3. **From User Stories**:
   - 3 acceptance scenarios → T006-T008 integration tests [P]
   
4. **From Research/Quickstart**:
   - Setup tasks T001-T003

5. **Ordering**:
   - Setup → Tests → Core → Integration → Polish
   - Dependencies block parallel execution

## Validation Checklist
*GATE: Checked by main() before returning*

- [x] All contracts have corresponding tests
- [x] All entities have model tasks (none required)
- [x] All tests come before implementation
- [x] Parallel tasks truly independent
- [x] Each task specifies exact file path
- [x] No task modifies same file as another [P] task</content>
<parameter name="filePath">/home/boggss/espasyoMLS/specs/001-create-the-landing/tasks.md