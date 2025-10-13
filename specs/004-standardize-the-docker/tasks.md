# Tasks: Standardize Docker Ports

**Input**: Design documents from `/specs/004-standardize-the-docker/`
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
- **Infrastructure project**: `espasyo-infrastructure/`, `espasyo-backend/`
- **Configuration files**: Docker Compose YAML, shell scripts
- **Documentation**: specs/, README files

## Phase 3.1: Setup
- [ ] T001 Create port validation script in `espasyo-infrastructure/scripts/validate-ports.sh`
- [ ] T002 Create port allocation registry in `espasyo-infrastructure/config/port-blocks.yaml`
- [ ] T003 [P] Set up port conflict detection tooling

## Phase 3.2: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.3
**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**
- [ ] T004 [P] Contract test for port block validation in `espasyo-infrastructure/tests/contracts/test_port_ranges.sh`
- [ ] T005 [P] Contract test for service assignment validation in `espasyo-infrastructure/tests/contracts/test_service_assignment.sh`
- [ ] T006 [P] Integration test for Docker Compose port conflicts in `espasyo-infrastructure/tests/integration/test_docker_conflicts.sh`
- [ ] T007 [P] Integration test for service connectivity validation in `espasyo-infrastructure/tests/integration/test_service_connectivity.sh`

## Phase 3.3: Core Implementation (ONLY after tests are failing)
- [ ] T008 [P] PortBlock entity implementation in `espasyo-infrastructure/scripts/port-block-manager.sh`
- [ ] T009 [P] Service entity implementation in `espasyo-infrastructure/scripts/service-manager.sh`
- [ ] T010 [P] PortAssignment entity implementation in `espasyo-infrastructure/scripts/port-assignment-manager.sh`
- [ ] T011 Update eDSL port from 8080 to 5000 in `espasyo-infrastructure/docker-compose.local.yml`
- [ ] T012 Update Grafana port from 3001 to 6001 in `espasyo-infrastructure/monitoring/setup-monitoring.sh`
- [ ] T013 Create port migration validation script in `espasyo-infrastructure/scripts/migrate-ports.sh`
- [ ] T014 Update service dependency URLs for new ports

## Phase 3.4: Integration
- [ ] T015 Validate LocalStack port assignment (4566) in AWS services block
- [ ] T016 Update frontend environment variables for new eDSL port
- [ ] T017 Test inter-service communication with new ports
- [ ] T018 Update monitoring configuration for new Grafana port

## Phase 3.5: Polish
- [ ] T019 [P] Create port usage documentation in `espasyo-infrastructure/docs/port-standardization.md`
- [ ] T020 [P] Update infrastructure README with port block information
- [ ] T021 Performance validation of port assignments
- [ ] T022 Create automated port validation CI check
- [ ] T023 Execute quickstart validation scenarios

## Dependencies
- Tests (T004-T007) before implementation (T008-T014)
- T001-T003 before T004-T007 (setup before tests)
- T008-T010 before T011-T014 (entities before port updates)
- T011-T014 before T015-T018 (port updates before integration)
- Implementation before polish (T019-T023)

## Parallel Example
```
# Launch T004-T007 together:
Task: "Contract test for port block validation in espasyo-infrastructure/tests/contracts/test_port_ranges.sh"
Task: "Contract test for service assignment validation in espasyo-infrastructure/tests/contracts/test_service_assignment.sh"
Task: "Integration test for Docker Compose port conflicts in espasyo-infrastructure/tests/integration/test_docker_conflicts.sh"
Task: "Integration test for service connectivity validation in espasyo-infrastructure/tests/integration/test_service_connectivity.sh"
```

## Notes
- [P] tasks = different files, no dependencies
- Verify tests fail before implementing port changes
- Commit after each task to maintain working state
- Test service accessibility after each port change
- Rollback plan: revert Docker Compose changes if issues arise

## Task Generation Rules
*Applied during main() execution*

1. **From Contracts**:
   - Each contract file → contract test task [P]
   - Each validation scenario → implementation task

2. **From Data Model**:
   - Each entity (PortBlock, Service, PortAssignment) → manager script [P]
   - Relationships → validation logic

3. **From User Stories**:
   - Each acceptance scenario → integration test [P]
   - Quickstart steps → validation tasks

4. **Ordering**:
   - Setup → Tests → Entities → Port Updates → Integration → Polish
   - Dependencies block parallel execution

## Validation Checklist
*GATE: Checked by main() before returning*

- [ ] All contracts have corresponding tests
- [ ] All entities have manager implementations
- [ ] All tests come before implementation
- [ ] Parallel tasks truly independent
- [ ] Each task specifies exact file path
- [ ] No task modifies same file as another [P] task</content>
<parameter name="filePath">/home/boggss/espasyoMLS/specs/004-standardize-the-docker/tasks.md