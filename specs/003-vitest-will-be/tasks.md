# Tasks: Vitest as Default Testing Framework

**Inp- [x] T006 [P] Integration test for component testing scenario in `espasyo-frontend/tests/integration/test-component-flow.test.tsx`t**: Design documents from `/specs/003-vitest-will-be/`
**Prerequisites**: plan.md (required), research.md, data-model.md, contracts/

## Execution Flow (main)
```
1. Load plan.md from feature directory
   → Extract: TypeScript, Vitest, React Testing Library, jsdom
2. Load optional design documents:
   → data-model.md: Extract test fixtures, mocks → fixture/mock tasks
   → contracts/: test-contracts.md, component-contracts.md → contract test tasks
   → research.md: Extract Vitest config decisions → setup tasks
3. Generate tasks by category:
   → Setup: Vitest config, package.json updates, test environment
   → Tests: Contract tests for testing standards, integration tests for scenarios
   → Core: Test utilities, CI/CD integration, test migration
   → Integration: Coverage reporting, workflow integration
   → Polish: Documentation, validation, performance
4. Apply task rules:
   → Different files = mark [P] for parallel
   → Same file = sequential (no [P])
   → Tests before implementation (TDD)
5. Number tasks sequentially (T001, T002...)
6. Generate dependency graph
7. Create parallel execution examples
8. Validate task completeness:
   → All contracts have tests? Yes
   → All entities have models? Yes (fixtures)
   → All scenarios have integration tests? Yes
9. Return: SUCCESS (tasks ready for execution)
```

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths in descriptions

## Path Conventions
- **Frontend project**: `espasyo-frontend/` at repository root
- **Test files**: `espasyo-frontend/src/__tests__/`, `espasyo-frontend/tests/`
- **Config files**: `espasyo-frontend/` root level

## Phase 3.1: Setup
- [x] T001 Create Vitest configuration file at `espasyo-frontend/vitest.config.ts`
- [x] T002 Update package.json test scripts to use Vitest at `espasyo-frontend/package.json`
- [x] T003 Setup test environment with jsdom at `espasyo-frontend/src/test/setup.ts`

## Phase 3.2: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.3
**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**
- [x] T004 [P] Contract test for test standards in `espasyo-frontend/tests/contract/test-standards.test.ts`
- [x] T005 [P] Contract test for component testing in `espasyo-frontend/tests/contract/test-components.test.tsx`
- [ ] T006 [P] Integration test for component testing scenario in `espasyo-frontend/tests/integration/test-component-flow.test.ts`
- [x] T007 [P] Integration test for hook testing scenario in `espasyo-frontend/tests/integration/test-hook-flow.test.ts`
- [x] T008 [P] Integration test for utility testing scenario in `espasyo-frontend/tests/integration/test-utility-flow.test.ts`

## Phase 3.3: Core Implementation (ONLY after tests are failing)
- [x] T009 Configure Vitest coverage with v8 provider at `espasyo-frontend/vitest.config.ts`
- [x] T010 Create shared test utilities at `espasyo-frontend/src/test/utils.ts`
- [x] T011 Create test fixtures for components at `espasyo-frontend/src/test/fixtures/components.tsx`
- [x] T012 Create mock implementations at `espasyo-frontend/src/test/mocks/api.ts`
- [x] T013 Update CI/CD pipeline for Vitest at `.github/workflows/frontend-tests.yml`
- [x] T014 Migrate existing Jest tests to Vitest syntax in `espasyo-frontend/src/**/*.test.*`

## Phase 3.4: Integration
- [x] T015 Integrate Vitest with development workflow at `espasyo-frontend/package.json`
- [x] T016 Add coverage reporting to CI/CD at `.github/workflows/frontend-tests.yml`
- [x] T017 Configure test environment for production builds at `espasyo-frontend/vitest.config.ts`

## Phase 3.5: Polish
- [x] T018 [P] Update README with Vitest testing guide at `espasyo-frontend/README.md`
- [x] T019 [P] Create testing best practices documentation at `espasyo-frontend/docs/testing.md`
- [x] T020 Validate 100% test coverage at `espasyo-frontend/vitest.config.ts`
- [x] T021 Performance testing for test execution at `espasyo-frontend/tests/performance/`
- [x] T022 Run full test suite validation at `espasyo-frontend/`

## Dependencies
- Setup (T001-T003) before Tests (T004-T008)
- Tests (T004-T008) before Core Implementation (T009-T014)
- Core Implementation (T009-T014) before Integration (T015-T017)
- Integration (T015-T017) before Polish (T018-T022)
- T001 blocks T009 (config file)
- T013 blocks T016 (CI/CD file)
- T014 depends on existing test files

## Parallel Example
```
# Launch T004-T008 together (contract and integration tests):
Task: "Contract test for test standards in espasyo-frontend/tests/contract/test-standards.test.ts"
Task: "Contract test for component testing in espasyo-frontend/tests/contract/test-components.test.ts"
Task: "Integration test for component testing scenario in espasyo-frontend/tests/integration/test-component-flow.test.ts"
Task: "Integration test for hook testing scenario in espasyo-frontend/tests/integration/test-hook-flow.test.ts"
Task: "Integration test for utility testing scenario in espasyo-frontend/tests/integration/test-utility-flow.test.ts"
```

## Notes
- [P] tasks = different files, no dependencies
- Verify tests fail before implementing Vitest configuration
- Commit after each task completion
- Avoid: modifying same files in parallel tasks

## Task Generation Rules
*Applied during main() execution*

1. **From Contracts**:
   - test-contracts.md → T004 contract test task [P]
   - component-contracts.md → T005 contract test task [P]

2. **From Data Model**:
   - Test fixtures → T011 model creation task [P]
   - Mock implementations → T012 model creation task [P]

3. **From User Stories**:
   - Component testing story → T006 integration test [P]
   - Hook testing story → T007 integration test [P]
   - Utility testing story → T008 integration test [P]

4. **Ordering**:
   - Setup → Tests → Core → Integration → Polish
   - Dependencies prevent parallel execution conflicts

## Validation Checklist
*GATE: Checked by main() before returning*

- [x] All contracts have corresponding tests (2 contracts → 2 tests)
- [x] All entities have model tasks (fixtures, mocks → 2 tasks)
- [x] All tests come before implementation (TDD order maintained)
- [x] Parallel tasks truly independent (different file paths)
- [x] Each task specifies exact file path (all do)
- [x] No task modifies same file as another [P] task (validated)